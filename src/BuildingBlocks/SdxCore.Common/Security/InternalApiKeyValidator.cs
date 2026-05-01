using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace SdxCore.Common.Security;

/// <summary>
/// Utility class for validating internal API key calls between microservices.
/// Provides secure validation of internal service-to-service communication.
/// </summary>
public static class InternalApiKeyValidator
{
    /// <summary>
    /// Header name for internal API key authentication.
    /// </summary>
    public const string InternalApiKeyHeader = "X-Internal-API-Key";

    /// <summary>
    /// Configuration key for the internal API key.
    /// </summary>
    public const string InternalApiKeyConfigKey = "Authentication:InternalApiKey";

    /// <summary>
    /// Verifies that the request is coming from an internal service (like Gateway middleware).
    /// Uses internal API key authentication to restrict access to internal endpoints.
    /// </summary>
    /// <param name="request">The HTTP request to validate.</param>
    /// <param name="configuration">Configuration service to get the expected API key.</param>
    /// <param name="logger">Logger for security events.</param>
    /// <returns>True if the request is from an internal service, false otherwise.</returns>
    public static bool IsInternalServiceCall(HttpRequest request, IConfiguration configuration, ILogger? logger = null)
    {
        // Check for internal API key header
        var internalApiKey = request.Headers[InternalApiKeyHeader].FirstOrDefault();
        var expectedApiKey = configuration[InternalApiKeyConfigKey];

        if (string.IsNullOrEmpty(expectedApiKey))
        {
            logger?.LogError("Internal API key not configured at {ConfigKey}", InternalApiKeyConfigKey);
            return false;
        }

        if (string.IsNullOrEmpty(internalApiKey))
        {
            logger?.LogWarning("Missing {HeaderName} header for internal endpoint access from {RemoteIpAddress}", 
                InternalApiKeyHeader, request.HttpContext.Connection.RemoteIpAddress);
            return false;
        }

        var isValidKey = string.Equals(internalApiKey, expectedApiKey, StringComparison.Ordinal);
        
        if (!isValidKey)
        {
            logger?.LogWarning("Invalid {HeaderName} header for internal endpoint access from {RemoteIpAddress}", 
                InternalApiKeyHeader, request.HttpContext.Connection.RemoteIpAddress);
        }
        else
        {
            logger?.LogDebug("Valid internal API key provided from {RemoteIpAddress}", 
                request.HttpContext.Connection.RemoteIpAddress);
        }

        return isValidKey;
    }

    /// <summary>
    /// Verifies that the request is coming from the Gateway middleware specifically.
    /// This is a convenience method that calls IsInternalServiceCall with Gateway-specific logging.
    /// </summary>
    /// <param name="request">The HTTP request to validate.</param>
    /// <param name="configuration">Configuration service to get the expected API key.</param>
    /// <param name="logger">Logger for security events.</param>
    /// <returns>True if the request is from Gateway, false otherwise.</returns>
    public static bool IsInternalGatewayCall(HttpRequest request, IConfiguration configuration, ILogger? logger = null)
    {
        var isValid = IsInternalServiceCall(request, configuration, logger);
        
        if (isValid)
        {
            logger?.LogDebug("Validated internal Gateway call from {RemoteIpAddress}", 
                request.HttpContext.Connection.RemoteIpAddress);
        }
        else
        {
            logger?.LogWarning("Unauthorized access attempt to Gateway-only endpoint from {RemoteIpAddress}", 
                request.HttpContext.Connection.RemoteIpAddress);
        }

        return isValid;
    }
}