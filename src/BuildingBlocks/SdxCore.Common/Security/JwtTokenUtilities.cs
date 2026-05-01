using Microsoft.Extensions.Logging;
using SdxCore.Common.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace SdxCore.Common.Security;

/// <summary>
/// Utility class for working with JWT tokens across microservices.
/// Provides common functionality for token parsing and claims extraction.
/// </summary>
public static class JwtTokenUtilities
{
    /// <summary>
    /// Extracts claims from a JWT token without validation.
    /// This method assumes the token has already been validated by the authentication service.
    /// </summary>
    /// <param name="token">The JWT token to extract claims from.</param>
    /// <param name="logger">Optional logger for error reporting.</param>
    /// <returns>Token claims information, or empty claims if extraction fails.</returns>
    public static TokenClaims ExtractTokenClaims(string token, ILogger? logger = null)
    {
        try
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            
            if (!tokenHandler.CanReadToken(token))
            {
                logger?.LogWarning("Token is not in valid JWT format during claims extraction");
                return new TokenClaims();
            }

            var jwtToken = tokenHandler.ReadJwtToken(token);
            var claims = jwtToken.Claims.ToList();

            // Extract common claims using multiple possible claim types
            var userId = ExtractClaimValue(claims, 
                ClaimTypes.NameIdentifier, "sub", "user_id", "userId");

            var username = ExtractClaimValue(claims, 
                ClaimTypes.Name, "username", "preferred_username");

            var email = ExtractClaimValue(claims, 
                ClaimTypes.Email, "email");

            var roles = ExtractClaimValues(claims, 
                ClaimTypes.Role, "role", "roles");

            var provider = ExtractClaimValue(claims, 
                "provider", "auth_provider", "identity_provider");

            // Extract expiration time
            DateTimeOffset? expiresAt = null;
            if (jwtToken.ValidTo != DateTime.MinValue)
            {
                expiresAt = new DateTimeOffset(jwtToken.ValidTo);
            }

            return new TokenClaims
            {
                UserId = userId,
                Username = username,
                Email = email,
                Roles = roles,
                Provider = provider,
                ExpiresAt = expiresAt
            };
        }
        catch (Exception ex)
        {
            logger?.LogError(ex, "Error extracting claims from JWT token");
            return new TokenClaims();
        }
    }

    /// <summary>
    /// Extracts the Authorization header from an HTTP request and returns the bearer token.
    /// </summary>
    /// <param name="authorizationHeader">The Authorization header value.</param>
    /// <returns>The bearer token if valid, null otherwise.</returns>
    public static string? ExtractBearerToken(string? authorizationHeader)
    {
        if (string.IsNullOrWhiteSpace(authorizationHeader))
        {
            return null;
        }

        if (!authorizationHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        var token = authorizationHeader.Substring("Bearer ".Length).Trim();
        return string.IsNullOrWhiteSpace(token) ? null : token;
    }

    /// <summary>
    /// Validates the format of a JWT token without cryptographic validation.
    /// </summary>
    /// <param name="token">The token to validate.</param>
    /// <returns>True if the token has a valid JWT format, false otherwise.</returns>
    public static bool IsValidJwtFormat(string token)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            return false;
        }

        try
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            return tokenHandler.CanReadToken(token);
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Extracts a single claim value from a list of claims, trying multiple claim types.
    /// </summary>
    /// <param name="claims">The list of claims to search.</param>
    /// <param name="claimTypes">The claim types to search for, in order of preference.</param>
    /// <returns>The first matching claim value, or null if not found.</returns>
    private static string? ExtractClaimValue(IList<Claim> claims, params string[] claimTypes)
    {
        foreach (var claimType in claimTypes)
        {
            var claim = claims.FirstOrDefault(c => 
                string.Equals(c.Type, claimType, StringComparison.OrdinalIgnoreCase));
            
            if (claim != null && !string.IsNullOrWhiteSpace(claim.Value))
            {
                return claim.Value;
            }
        }

        return null;
    }

    /// <summary>
    /// Extracts multiple claim values from a list of claims, trying multiple claim types.
    /// </summary>
    /// <param name="claims">The list of claims to search.</param>
    /// <param name="claimTypes">The claim types to search for.</param>
    /// <returns>A list of matching claim values.</returns>
    private static IReadOnlyList<string> ExtractClaimValues(IList<Claim> claims, params string[] claimTypes)
    {
        var values = new List<string>();

        foreach (var claimType in claimTypes)
        {
            var matchingClaims = claims.Where(c => 
                string.Equals(c.Type, claimType, StringComparison.OrdinalIgnoreCase) &&
                !string.IsNullOrWhiteSpace(c.Value));

            values.AddRange(matchingClaims.Select(c => c.Value));
        }

        return values.Distinct().ToList();
    }
}