using System.Security.Claims;

namespace SdxCore.Identity.Domain.DTOs;

/// <summary>
/// Represents the result of an authentication attempt.
/// </summary>
public sealed record AuthenticationResult
{
    /// <summary>
    /// Indicates whether the authentication was successful.
    /// </summary>
    public required bool IsSuccess { get; init; }

    /// <summary>
    /// The issued authentication token. Non-null when IsSuccess is true.
    /// </summary>
    public AuthToken? Token { get; init; }
    
    /// <summary>
    /// Error code when authentication fails. Null when IsSuccess is true.
    /// </summary>
    public string? ErrorCode { get; init; }

    /// <summary>
    /// Human-readable error message when authentication fails. Null when IsSuccess is true.
    /// </summary>
    public string? ErrorMessage { get; init; }

    /// <summary>
    /// User claims extracted from the authentication provider.
    /// </summary>
    public IReadOnlyList<Claim> Claims { get; init; } = [];
}
