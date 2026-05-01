namespace SdxCore.Common.Models;

/// <summary>
/// Token validation response model containing validation result and user information.
/// Used for communication between Gateway and Identity service.
/// </summary>
public sealed record TokenValidationResponse
{
    /// <summary>
    /// Indicates whether the token is valid.
    /// </summary>
    public required bool IsValid { get; init; }

    /// <summary>
    /// User identifier extracted from the token.
    /// </summary>
    public string? UserId { get; init; }

    /// <summary>
    /// Username extracted from the token.
    /// </summary>
    public string? Username { get; init; }

    /// <summary>
    /// Email address extracted from the token.
    /// </summary>
    public string? Email { get; init; }

    /// <summary>
    /// User roles extracted from the token.
    /// </summary>
    public IReadOnlyList<string> Roles { get; init; } = [];

    /// <summary>
    /// Authentication provider that issued the token (InHouse, SAML, OAuth, OIDC, JWT).
    /// </summary>
    public string? Provider { get; init; }

    /// <summary>
    /// Token expiration timestamp.
    /// </summary>
    public DateTimeOffset? ExpiresAt { get; init; }

    /// <summary>
    /// Timestamp when the validation was performed.
    /// </summary>
    public required DateTimeOffset ValidatedAt { get; init; }
}