using System.Net.Http.Headers;
using System.Text.Json;
using SdxCore.Common.Models;
using SdxCore.Common.Routing;
using SdxCore.Common.Http;
using System.ComponentModel.DataAnnotations;
using System.IO;

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
    private readonly PublicRouteValidator _publicRouteValidator;
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

        // Initialize public route validator
        _publicRouteValidator = new PublicRouteValidator(_configuration);

        // Get Identity service URL for token validation
        _identityServiceUrl = _configuration["Authentication:IdentityServiceUrl"]
            ?? throw new InvalidOperationException("Authentication:IdentityServiceUrl is not configured");
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var path = context.Request.Path.Value?.ToLowerInvariant() ?? string.Empty;

        // ALWAYS ADD HEADERS
        // (public + private routes)
        EnrichHeaders(context);

        // Check if this is a public route that doesn't require authentication
        if (_publicRouteValidator.IsPublicRoute(path))
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
                await HttpResponseUtilities.WriteUnauthorizedResponseAsync(context, "INVALID_TOKEN", "Token is invalid, expired, or revoked");
                return;
            }

            AttachIdentityHeaders(context, validationResult);

            // Token is valid - continue to downstream service
            _logger.LogDebug("Token validated successfully for route: {Path}", path);
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error validating token for route: {Path}", path);
            await HttpResponseUtilities.WriteUnauthorizedResponseAsync(context, "TOKEN_VALIDATION_ERROR", "An error occurred while validating the token");
        }
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
        AttachInternalApiKey(httpClient);

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

    private static void EnrichHeaders(HttpContext context)
    {
        var headers = context.Request.Headers;

        // Trace
        headers["X-Trace-Id"] = context.TraceIdentifier;
        headers["X-Correlation-Id"] = context.TraceIdentifier;

        // IP (proxy-safe)
        var forwardedFor = headers["X-Forwarded-For"].FirstOrDefault();

        var clientIp = forwardedFor ??
                       context.Connection.RemoteIpAddress?.ToString();

        if (!string.IsNullOrEmpty(clientIp))
        {
            headers["X-Client-Ip"] = clientIp.Split(',')[0].Trim();
        }

        if (!string.IsNullOrEmpty(forwardedFor))
        {
            headers["X-Forwarded-For"] = forwardedFor;
        }

        // User-Agent
        var userAgent = headers.UserAgent.ToString();
        headers["X-User-Agent"] = userAgent;

        // Device detection
        var device =
            userAgent.Contains("Mobile", StringComparison.OrdinalIgnoreCase) ? "Mobile" :
            userAgent.Contains("Windows", StringComparison.OrdinalIgnoreCase) ? "Desktop-Windows" :
            userAgent.Contains("Mac", StringComparison.OrdinalIgnoreCase) ? "Desktop-Mac" :
            "Unknown";

        headers["X-Device"] = device;

        // Gateway info
        headers["X-Gateway"] = "YARP";
        headers["X-Gateway-Time"] = DateTime.UtcNow.ToString("O");
    }

    private static void AttachIdentityHeaders(
    HttpContext context,
    TokenValidationResponse validationResult)
    {
        var headers = context.Request.Headers;

        // Add user context to headers for downstream services
        if (!string.IsNullOrEmpty(validationResult.UserId))
        {
            context.Request.Headers["X-User-Id"] = validationResult.UserId;
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
    }

    private bool AttachInternalApiKey(HttpClient httpClient)
    {
        var internalApiKey = _configuration["Authentication:InternalApiKey"];

        if (string.IsNullOrWhiteSpace(internalApiKey))
        {
            _logger.LogError("Internal API key not configured for Gateway authentication");
            return false;
        }

        // Avoid duplicate header issues
        if (httpClient.DefaultRequestHeaders.Contains("X-Internal-API-Key"))
            httpClient.DefaultRequestHeaders.Remove("X-Internal-API-Key");

        httpClient.DefaultRequestHeaders.Add("X-Internal-API-Key", internalApiKey);

        return true;
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