using SdxCore.Identity.Application.Interfaces.Services;

namespace SdxCore.Identity.API.Middleware;

/// <summary>
/// Middleware that validates JWT tokens from the Authorization header.
/// Returns HTTP 401 for invalid, expired, or revoked tokens.
/// </summary>
public sealed class TokenValidationMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<TokenValidationMiddleware> _logger;

    public TokenValidationMiddleware(
        RequestDelegate next,
        ILogger<TokenValidationMiddleware> logger)
    {
        _next = next ?? throw new ArgumentNullException(nameof(next));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task InvokeAsync(HttpContext context, IAuthenticationService authenticationService)
    {
        // Skip validation for login endpoint only (not test-protected)
        if (context.Request.Path.StartsWithSegments("/api/auth/login"))
        {
            await _next(context);
            return;
        }

        // Extract bearer token from Authorization header
        var authorizationHeader = context.Request.Headers.Authorization.FirstOrDefault();
        
        if (string.IsNullOrWhiteSpace(authorizationHeader))
        {
            // No token provided - let the request continue (authorization is separate concern)
            await _next(context);
            return;
        }

        // Check if it's a Bearer token
        if (!authorizationHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
        {
            _logger.LogWarning("Invalid authorization header format");
            context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            await context.Response.WriteAsJsonAsync(new
            {
                ErrorCode = "INVALID_TOKEN_FORMAT",
                ErrorMessage = "Authorization header must use Bearer scheme"
            });
            return;
        }

        // Extract the token
        var token = authorizationHeader.Substring("Bearer ".Length).Trim();

        if (string.IsNullOrWhiteSpace(token))
        {
            _logger.LogWarning("Empty bearer token provided");
            context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            await context.Response.WriteAsJsonAsync(new
            {
                ErrorCode = "EMPTY_TOKEN",
                ErrorMessage = "Bearer token is empty"
            });
            return;
        }

        // Validate the token
        try
        {
            var isValid = await authenticationService.ValidateTokenAsync(token, context.RequestAborted);

            if (!isValid)
            {
                _logger.LogWarning("Token validation failed for token");
                context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                await context.Response.WriteAsJsonAsync(new
                {
                    ErrorCode = "INVALID_TOKEN",
                    ErrorMessage = "Token is invalid, expired, or revoked"
                });
                return;
            }

            // Token is valid - continue to next middleware
            await _next(context);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error validating token");
            context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            await context.Response.WriteAsJsonAsync(new
            {
                ErrorCode = "TOKEN_VALIDATION_ERROR",
                ErrorMessage = "An error occurred while validating the token"
            });
        }
    }
}

/// <summary>
/// Extension methods for registering TokenValidationMiddleware.
/// </summary>
public static class TokenValidationMiddlewareExtensions
{
    /// <summary>
    /// Adds the TokenValidationMiddleware to the application pipeline.
    /// </summary>
    public static IApplicationBuilder UseTokenValidation(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<TokenValidationMiddleware>();
    }
}
