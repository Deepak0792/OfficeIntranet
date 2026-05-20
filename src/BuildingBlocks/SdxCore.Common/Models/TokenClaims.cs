namespace SdxCore.Common.Models;

/// <summary>
/// Internal helper class for extracting and representing JWT token claims.
/// </summary>
public sealed record TokenClaims
{
    /// <summary>
    /// User identifier from the token.
    /// </summary>
    public int UserId { get; init; }

    /// <summary>
    /// Username from the token.
    /// </summary>
    public string? Username { get; init; }

    /// <summary>
    /// Email address from the token.
    /// </summary>
    public string? Email { get; init; }

    /// <summary>
    /// User roles from the token.
    /// </summary>
    public IReadOnlyList<string> Roles { get; init; } = [];

    /// <summary>
    /// Authentication provider that issued the token.
    /// </summary>
    public string? Provider { get; init; }

    /// <summary>
    /// Token expiration timestamp.
    /// </summary>
    public DateTime? ExpiresAt { get; init; }
}