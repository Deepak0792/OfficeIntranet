using Microsoft.AspNetCore.Http;
using SdxCore.Common.Security;

namespace SdxCore.Common.Extensions;

/// <summary>
/// Extension methods for HttpContext to provide common functionality across microservices.
/// </summary>
public static class HttpContextExtensions
{
    /// <summary>
    /// Gets the user ID from the X-User-Id header that was set by the Gateway.
    /// </summary>
    /// <param name="context">The HTTP context.</param>
    /// <returns>The user ID if present, null otherwise.</returns>
    public static string? GetUserIdFromGateway(this HttpContext context)
    {
        return context.Request.Headers["X-User-Id"].FirstOrDefault();
    }

    /// <summary>
    /// Gets the username from the X-Username header that was set by the Gateway.
    /// </summary>
    /// <param name="context">The HTTP context.</param>
    /// <returns>The username if present, null otherwise.</returns>
    public static string? GetUsernameFromGateway(this HttpContext context)
    {
        return context.Request.Headers["X-Username"].FirstOrDefault();
    }

    /// <summary>
    /// Gets the user email from the X-User-Email header that was set by the Gateway.
    /// </summary>
    /// <param name="context">The HTTP context.</param>
    /// <returns>The user email if present, null otherwise.</returns>
    public static string? GetUserEmailFromGateway(this HttpContext context)
    {
        return context.Request.Headers["X-User-Email"].FirstOrDefault();
    }

    /// <summary>
    /// Gets the user roles from the X-User-Roles header that was set by the Gateway.
    /// </summary>
    /// <param name="context">The HTTP context.</param>
    /// <returns>A list of user roles, empty if not present.</returns>
    public static IReadOnlyList<string> GetUserRolesFromGateway(this HttpContext context)
    {
        var rolesHeader = context.Request.Headers["X-User-Roles"].FirstOrDefault();
        
        if (string.IsNullOrWhiteSpace(rolesHeader))
        {
            return [];
        }

        return rolesHeader.Split(',', StringSplitOptions.RemoveEmptyEntries)
                         .Select(role => role.Trim())
                         .Where(role => !string.IsNullOrWhiteSpace(role))
                         .ToList();
    }

    /// <summary>
    /// Gets the authentication provider from the X-Auth-Provider header that was set by the Gateway.
    /// </summary>
    /// <param name="context">The HTTP context.</param>
    /// <returns>The authentication provider if present, null otherwise.</returns>
    public static string? GetAuthProviderFromGateway(this HttpContext context)
    {
        return context.Request.Headers["X-Auth-Provider"].FirstOrDefault();
    }

    /// <summary>
    /// Gets the bearer token from the Authorization header.
    /// </summary>
    /// <param name="context">The HTTP context.</param>
    /// <returns>The bearer token if present and valid, null otherwise.</returns>
    public static string? GetBearerToken(this HttpContext context)
    {
        var authorizationHeader = context.Request.Headers["Authorization"].FirstOrDefault();
        return JwtTokenUtilities.ExtractBearerToken(authorizationHeader);
    }

    /// <summary>
    /// Checks if the current request has user context headers from the Gateway.
    /// This indicates the request was authenticated and processed by the Gateway.
    /// </summary>
    /// <param name="context">The HTTP context.</param>
    /// <returns>True if user context headers are present, false otherwise.</returns>
    public static bool HasGatewayUserContext(this HttpContext context)
    {
        return !string.IsNullOrWhiteSpace(context.GetUserIdFromGateway());
    }

    /// <summary>
    /// Gets the client IP address from the request, considering proxy headers.
    /// </summary>
    /// <param name="context">The HTTP context.</param>
    /// <returns>The client IP address if available, null otherwise.</returns>
    public static string? GetClientIpAddress(this HttpContext context)
    {
        // Check for forwarded IP headers first (common in load balancer/proxy scenarios)
        var forwardedFor = context.Request.Headers["X-Forwarded-For"].FirstOrDefault();
        if (!string.IsNullOrWhiteSpace(forwardedFor))
        {
            // X-Forwarded-For can contain multiple IPs, take the first one
            var firstIp = forwardedFor.Split(',').FirstOrDefault()?.Trim();
            if (!string.IsNullOrWhiteSpace(firstIp))
            {
                return firstIp;
            }
        }

        var realIp = context.Request.Headers["X-Real-IP"].FirstOrDefault();
        if (!string.IsNullOrWhiteSpace(realIp))
        {
            return realIp;
        }

        // Fall back to connection remote IP
        return context.Connection.RemoteIpAddress?.ToString();
    }

    /// <summary>
    /// Checks if the request is coming from a local/loopback address.
    /// </summary>
    /// <param name="context">The HTTP context.</param>
    /// <returns>True if the request is from localhost, false otherwise.</returns>
    public static bool IsLocalRequest(this HttpContext context)
    {
        var remoteIp = context.Connection.RemoteIpAddress;
        
        if (remoteIp == null)
        {
            return false;
        }

        // Check for loopback addresses
        if (remoteIp.IsIPv4MappedToIPv6)
        {
            remoteIp = remoteIp.MapToIPv4();
        }

        return System.Net.IPAddress.IsLoopback(remoteIp);
    }
}