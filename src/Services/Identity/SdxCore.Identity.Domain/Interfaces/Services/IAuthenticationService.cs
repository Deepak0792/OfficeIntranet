using SdxCore.Identity.Domain.DTOs.Request;
using SdxCore.Identity.Domain.DTOs.Response;

namespace SdxCore.Identity.Domain.Interfaces.Services;

/// <summary>
/// Central authentication service interface.
/// Orchestrates authentication operations by resolving providers, delegating authentication,
/// issuing tokens, and recording audit events.
/// </summary>
public interface IAuthenticationService
{
    /// <summary>
    /// Authenticates a user based on the provided request.
    /// </summary>
    /// <param name="request">Authentication request containing credentials and protocol-specific parameters.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>Authentication result containing success status, token, and claims.</returns>
    Task<AuthenticationResponse> AuthenticateAsync(AuthenticationRequest request, CancellationToken ct = default);

    /// <summary>
    /// Validates a JWT token.
    /// </summary>
    /// <param name="token">JWT token to validate.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>True if the token is valid, not expired, and not revoked; otherwise false.</returns>
    Task<bool> ValidateTokenAsync(string token, CancellationToken ct = default);

    /// <summary>
    /// Revokes a JWT token before its expiration.
    /// </summary>
    /// <param name="token">JWT token to revoke.</param>
    /// <param name="refreshToken">Refresh Token to revoke.</param>
    /// <param name="ct">Cancellation token.</param>
    Task RevokeTokenAsync(string token, string refreshToken, CancellationToken ct = default);
}
