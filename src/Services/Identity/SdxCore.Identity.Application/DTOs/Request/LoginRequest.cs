namespace SdxCore.Identity.Domain.DTOs.Request;

/// <summary>
/// Login request model for the API endpoint.
/// </summary>
public sealed record LoginRequest
{
    /// <summary>
    /// Username for InHouse authentication.
    /// </summary>
    public string? Username { get; init; }

    /// <summary>
    /// Password for InHouse authentication.
    /// </summary>
    public string? Password { get; init; }

    /// <summary>
    /// SAML assertion for SAML authentication.
    /// </summary>
    public string? SamlAssertion { get; init; }

    /// <summary>
    /// OAuth authorization code.
    /// </summary>
    public string? OAuthCode { get; init; }

    /// <summary>
    /// OpenID Connect ID token.
    /// </summary>
    public string? IdToken { get; init; }

    /// <summary>
    /// JWT bearer token for JWT authentication.
    /// </summary>
    public string? BearerToken { get; init; }

    /// <summary>
    /// Additional protocol-specific parameters.
    /// </summary>
    public IDictionary<string, string>? ExtraParameters { get; init; }
}