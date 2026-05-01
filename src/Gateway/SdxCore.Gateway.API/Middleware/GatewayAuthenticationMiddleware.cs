using System.Net.Http.Headers;
using System.Text.Json;

namespace SdxCore.Gateway.API.Middleware;

/// <summary>
/// Gateway middleware that validates JWT tokens before forwarding requests to downstream services.
/// Delegates all token validation, error handling, and claims extraction to the Identity service.
/// </summary>
public sealed class GatewayAuthenticationMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IConfiguration _configuration;
    private readonly ILogger<GatewayAuthenticationMiddleware> _logger;
    private readonly HashSet<string> _publicRoutes;
    private readonly string _identityServiceUrl;

    public GatewayAuthenticationMiddleware(
        RequestDelegate next,
        IHttpClientFactory httpClientFactory,
        IConfiguration configuration,
        ILogger<GatewayAuthenticationMiddleware> logger)
    {
        _next = next ?? throw new ArgumentNullException(nameof(next));
        _httpClientFactory = httpClientFactory ?? throw new ArgumentNullException(nameof(httpClientFactory));
        _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));

        // Load public routes that don't require authentication
        _publicRoutes = LoadPublicRoutes();
        
        // Get Identity service URL for token validation
        _identityServiceUrl = _configuration["Authentication:IdentityServiceUrl"] 
            ?? throw new InvalidOperationException("Authentication:IdentityServiceUrl is not configured");
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var path = context.Request.Path.Value?.ToLowerInvariant() ?? string.Empty;

        // Check if this is a public route that doesn't require authentication
        if (IsPublicRoute(path))
        {
            _logger.LogDebug("Allowing public route: {Path}", path);
            await _next(context);
            return;
        }

        // Validate the token with the Identity service (which handles ALL validation logic)
        try
        {
            var validationResult = await ValidateTokenWithIdentityService(context, context.RequestAborted);

            if (validationResult == null)
            {
                _logger.LogWarning("Token validation failed for route: {Path}", path);
                await WriteUnauthorizedResponse(context, "INVALID_TOKEN", "Token is invalid, expired, or revoked");
                return;
            }

            // Add user context to headers for downstream services
            if (!string.IsNullOrEmpty(validationResult.UserId))
            {
                context.Request.Headers["X-User-Id"] = validationResult.UserId;
                _logger.LogDebug("Added X-User-Id header: {UserId} for route: {Path}", validationResult.UserId, path);
            }

            if (!string.IsNullOrEmpty(validationResult.Username))
            {
                context.Request.Headers["X-Username"] = validationResult.Username;
            }

            if (!string.IsNullOrEmpty(validationResult.Email))
            {
                context.Request.Headers["X-User-Email"] = validationResult.Email;
            }

            if (validationResult.Roles.Any())
            {
                context.Request.Headers["X-User-Roles"] = string.Join(",", validationResult.Roles);
            }

            if (!string.IsNullOrEmpty(validationResult.Provider))
            {
                context.Request.Headers["X-Auth-Provider"] = validationResult.Provider;
            }

            // Token is valid - continue to downstream service
            _logger.LogDebug("Token validated successfully for route: {Path}", path);
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error validating token for route: {Path}", path);
            await WriteUnauthorizedResponse(context, "TOKEN_VALIDATION_ERROR", "An error occurred while validating the token");
        }
    }

    private HashSet<string> LoadPublicRoutes()
    {
        var publicRoutes = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        
        // Load from configuration
        var configRoutes = _configuration.GetSection("Authentication:PublicRoutes").Get<string[]>();
        if (configRoutes != null)
        {
            foreach (var route in configRoutes)
            {
                publicRoutes.Add(route.ToLowerInvariant());
            }
        }

        // Always allow health checks and login endpoints
        publicRoutes.Add("/health");
        publicRoutes.Add("/api/auth/login");

        _logger.LogInformation("Loaded {Count} public routes: {Routes}", 
            publicRoutes.Count, string.Join(", ", publicRoutes));

        return publicRoutes;
    }

    private bool IsPublicRoute(string path)
    {
        // Check exact matches first
        if (_publicRoutes.Contains(path))
        {
            return true;
        }

        // Check wildcard patterns (routes ending with /*)
        foreach (var publicRoute in _publicRoutes)
        {
            if (publicRoute.EndsWith("/*"))
            {
                var prefix = publicRoute.Substring(0, publicRoute.Length - 2);
                if (path.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
                {
                    return true;
                }
            }
        }

        return false;
    }

    /// <summary>
    /// Validates token with Identity service and returns user information if valid.
    /// Uses internal API key to authenticate Gateway calls to validate-token endpoint.
    /// </summary>
    private async Task<TokenValidationResponse?> ValidateTokenWithIdentityService(HttpContext context, CancellationToken cancellationToken)
    {
        using var httpClient = _httpClientFactory.CreateClient("IdentityService");
        
        // Set the base address if not already configured
        if (httpClient.BaseAddress == null)
        {
            httpClient.BaseAddress = new Uri(_identityServiceUrl);
        }

        // Add internal API key for authentication with Identity service
        var internalApiKey = _configuration["Authentication:InternalApiKey"];
        if (string.IsNullOrEmpty(internalApiKey))
        {
            _logger.LogError("Internal API key not configured for Gateway authentication");
            return null;
        }
        
        httpClient.DefaultRequestHeaders.Add("X-Internal-API-Key", internalApiKey);

        // Forward the Authorization header exactly as received (AuthController will handle all validation)
        var authorizationHeader = context.Request.Headers.Authorization.FirstOrDefault();
        if (!string.IsNullOrEmpty(authorizationHeader))
        {
            httpClient.DefaultRequestHeaders.Authorization = AuthenticationHeaderValue.Parse(authorizationHeader);
        }

        try
        {
            // Call the Identity service's INTERNAL token validation endpoint
            var response = await httpClient.PostAsync("/api/auth/validate-token", null, cancellationToken);
            
            if (!response.IsSuccessStatusCode)
            {
                // Log the error details for debugging but don't duplicate error handling
                var errorContent = await response.Content.ReadAsStringAsync(cancellationToken);
                _logger.LogDebug("Token validation failed with status {StatusCode}: {ErrorContent}", 
                    response.StatusCode, errorContent);
                return null;
            }

            // Parse the successful response
            var responseContent = await response.Content.ReadAsStringAsync(cancellationToken);
            var validationResult = JsonSerializer.Deserialize<TokenValidationResponse>(responseContent, new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase
            });

            return validationResult;
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "HTTP error while validating token with Identity service");
            return null;
        }
        catch (TaskCanceledException ex) when (ex.InnerException is TimeoutException)
        {
            _logger.LogError(ex, "Timeout while validating token with Identity service");
            return null;
        }
        catch (JsonException ex)
        {
            _logger.LogError(ex, "Error parsing token validation response from Identity service");
            return null;
        }
    }

    private static async Task WriteUnauthorizedResponse(HttpContext context, string errorCode, string errorMessage)
    {
        context.Response.StatusCode = StatusCodes.Status401Unauthorized;
        context.Response.ContentType = "application/json";

        var errorResponse = new
        {
            ErrorCode = errorCode,
            ErrorMessage = errorMessage,
            Timestamp = DateTimeOffset.UtcNow
        };

        var json = JsonSerializer.Serialize(errorResponse, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        });

        await context.Response.WriteAsync(json);
    }
}

/// <summary>
/// Token validation response model from Identity service.
/// </summary>
public sealed record TokenValidationResponse
{
    public bool IsValid { get; init; }
    public string? UserId { get; init; }
    public string? Username { get; init; }
    public string? Email { get; init; }
    public IReadOnlyList<string> Roles { get; init; } = [];
    public string? Provider { get; init; }
    public DateTimeOffset? ExpiresAt { get; init; }
    public DateTimeOffset ValidatedAt { get; init; }
}

/// <summary>
/// Extension methods for registering GatewayAuthenticationMiddleware.
/// </summary>
public static class GatewayAuthenticationMiddlewareExtensions
{
    /// <summary>
    /// Adds the GatewayAuthenticationMiddleware to the application pipeline.
    /// </summary>
    public static IApplicationBuilder UseGatewayAuthentication(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<GatewayAuthenticationMiddleware>();
    }
}