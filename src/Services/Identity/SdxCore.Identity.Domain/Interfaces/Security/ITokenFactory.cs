using System.Security.Claims;
using SdxCore.Identity.Domain.DTOs;

namespace SdxCore.Identity.Domain.Interfaces.Security;

/// <summary>
/// Token factory interface for JWT token operations.
/// Handles token issuance, validation, and revocation.
/// </summary>
public interface ITokenFactory
{
    /// <summary>
    /// Issues a signed JWT token containing the provided claims.
    /// </summary>
    /// <param name="claims">Claims to embed in the token.</param>
    /// <returns>Signed JWT token with expiration and metadata.</returns>
    AuthToken IssueToken(IEnumerable<Claim> claims);

    /// <summary>
    /// Validates a JWT token and extracts claims.
    /// </summary>
    /// <param name="token">JWT token to validate.</param>
    /// <returns>ClaimsPrincipal if valid; otherwise null.</returns>
    ClaimsPrincipal? ValidateToken(string token);

    /// <summary>
    /// Revokes a JWT token by adding it to the revocation list.
    /// </summary>
    /// <param name="token">JWT token to revoke.</param>
    void RevokeToken(string token);
}
