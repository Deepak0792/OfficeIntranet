namespace SdxCore.Identity.Domain.DTOs;

/// <summary>
/// Represents a JWT authentication token issued upon successful authentication.
/// </summary>
public sealed record AuthToken
{
    /// <summary>
    /// The JWT access token string.
    /// </summary>
    public required string AccessToken { get; init; }

    /// <summary>
    /// The timestamp when the token expires.
    /// </summary>
    public required DateTimeOffset ExpiresAt { get; init; }

    /// <summary>
    /// Optional refresh token for obtaining new access tokens.
    /// </summary>
    public string? RefreshToken { get; init; }

    /// <summary>
    /// The token type. Defaults to "Bearer".
    /// </summary>
    public required string TokenType { get; init; } = "Bearer";
}
