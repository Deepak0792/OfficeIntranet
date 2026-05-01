using System.IdentityModel.Tokens.Jwt;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text.Json;

namespace SdxCore.Gateway.API.Middleware;

/// <summary>
/// Gateway middleware that validates JWT tokens before forwarding requests to downstream services.
/// Supports selective authentication based on route configuration.
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

        // Extract bearer token from Authorization header
        var authorizationHeader = context.Request.Headers.Authorization.FirstOrDefault();
        
        if (string.IsNullOrWhiteSpace(authorizationHeader))
        {
            _logger.LogWarning("No authorization header provided for protected route: {Path}", path);
            await WriteUnauthorizedResponse(context, "MISSING_TOKEN", "Authorization header is required");
            return;
        }

        // Check if it's a Bearer token
        if (!authorizationHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
        {
            _logger.LogWarning("Invalid authorization header format for route: {Path}", path);
            await WriteUnauthorizedResponse(context, "INVALID_TOKEN_FORMAT", "Authorization header must use Bearer scheme");
            return;
        }

        // Extract the token
        var token = authorizationHeader.Substring("Bearer ".Length).Trim();

        if (string.IsNullOrWhiteSpace(token))
        {
            _logger.LogWarning("Empty bearer token provided for route: {Path}", path);
            await WriteUnauthorizedResponse(context, "EMPTY_TOKEN", "Bearer token is empty");
            return;
        }

        // Validate the token with the Identity service
        try
        {
            var isValid = await ValidateTokenWithIdentityService(token, context.RequestAborted);

            if (!isValid)
            {
                _logger.LogWarning("Token validation failed for route: {Path}", path);
                await WriteUnauthorizedResponse(context, "INVALID_TOKEN", "Token is invalid, expired, or revoked");
                return;
            }

            // Extract user ID from token and add to headers
            var userId = ExtractUserIdFromToken(token);
            if (!string.IsNullOrEmpty(userId))
            {
                context.Request.Headers["X-User-Id"] = userId;
                _logger.LogDebug("Added X-User-Id header: {UserId} for route: {Path}", userId, path);
            }
            else
            {
                _logger.LogWarning("Could not extract user ID from token for route: {Path}", path);
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

    private string? ExtractUserIdFromToken(string token)
    {
        try
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            
            // Check if the token is a valid JWT format
            if (!tokenHandler.CanReadToken(token))
            {
                _logger.LogWarning("Token is not in valid JWT format");
                return null;
            }

            // Read the token without validation (we already validated it with Identity service)
            var jwtToken = tokenHandler.ReadJwtToken(token);
            
            // Try to extract user ID from common claim types
            var userId = jwtToken.Claims.FirstOrDefault(c => 
                c.Type == ClaimTypes.NameIdentifier || 
                c.Type == "sub" || 
                c.Type == "user_id" ||
                c.Type == "userId")?.Value;

            if (string.IsNullOrEmpty(userId))
            {
                _logger.LogDebug("No user ID claim found in token. Available claims: {Claims}", 
                    string.Join(", ", jwtToken.Claims.Select(c => c.Type)));
            }

            return userId;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error extracting user ID from token");
            return null;
        }
    }

    private async Task<bool> ValidateTokenWithIdentityService(string token, CancellationToken cancellationToken)
    {
        using var httpClient = _httpClientFactory.CreateClient("IdentityService");
        
        // Set the base address if not already configured
        if (httpClient.BaseAddress == null)
        {
            httpClient.BaseAddress = new Uri(_identityServiceUrl);
        }

        // Add the token to the request
        httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        try
        {
            // Call the Identity service's token validation endpoint
            var response = await httpClient.GetAsync("/api/auth/test-protected", cancellationToken);
            
            // Return true if the response is successful (200 OK)
            return response.IsSuccessStatusCode;
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "HTTP error while validating token with Identity service");
            return false;
        }
        catch (TaskCanceledException ex) when (ex.InnerException is TimeoutException)
        {
            _logger.LogError(ex, "Timeout while validating token with Identity service");
            return false;
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