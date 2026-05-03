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
    /// The issued authentication refresh token. Non-null when IsSuccess is true.
    /// </summary>
    public string? RefreshToken { get; set; }

    public DateTimeOffset RefreshTokenExpiresAt { get; set; }

    /// <summary>
    /// The token type. Defaults to "Bearer".
    /// </summary>
    public required string TokenType { get; init; } = "Bearer";
}
