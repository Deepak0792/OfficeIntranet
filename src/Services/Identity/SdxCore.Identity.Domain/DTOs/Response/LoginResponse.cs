namespace SdxCore.Identity.Domain.DTOs.Response;

/// <summary>
/// Login response model containing the issued token.
/// </summary>
public sealed record LoginResponse
{
    /// <summary>
    /// The issued JWT access token.
    /// </summary>
    public required string AccessToken { get; init; }

    /// <summary>
    /// Token type (typically "Bearer").
    /// </summary>
    public required string TokenType { get; init; }

    /// <summary>
    /// Token expiration timestamp.
    /// </summary>
    public required DateTime ExpiresAt { get; init; }

    /// <summary>
    /// Optional refresh token for token renewal.
    /// </summary>
    public string? RefreshToken { get; init; }

    public required DateTime RefreshTokenExpiresAt { get; init; }
}