using SdxCore.Identity.Domain.DTOs;
using SdxCore.Identity.Domain.Enums;

namespace SdxCore.Identity.Domain.Interfaces.Providers;

/// <summary>
/// Common contract for all authentication provider implementations.
/// Each provider encapsulates protocol-specific authentication logic.
/// </summary>
public interface IAuthenticationProvider
{
    /// <summary>
    /// Gets the authentication protocol this provider handles.
    /// </summary>
    AuthProtocol Protocol { get; }

    /// <summary>
    /// Authenticates a user using protocol-specific logic.
    /// </summary>
    /// <param name="request">Authentication request containing credentials and protocol-specific parameters.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>Provider result containing success status, claims, or failure reason.</returns>
    Task<ProviderResult> AuthenticateAsync(AuthenticationRequest request, CancellationToken ct = default);
}
