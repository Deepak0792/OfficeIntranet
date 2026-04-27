namespace SdxCore.Identity.Domain.DTOs;

/// <summary>
/// Represents an authentication request containing credentials and protocol-specific parameters.
/// The protocol is determined from appsettings.json configuration, not from the request.
/// </summary>
public sealed record AuthenticationRequest
{
    /// <summary>
    /// Username for InHouse authentication. Required when Protocol is InHouse.
    /// </summary>
    public required string? Username { get; init; }

    /// <summary>
    /// Password for InHouse authentication. Required when Protocol is InHouse.
    /// </summary>
    public required string? Password { get; init; }

    /// <summary>
    /// SAML assertion for SAML authentication. Required when Protocol is SAML.
    /// </summary>
    public string? SamlAssertion { get; init; }

    /// <summary>
    /// OAuth authorization code. Required when Protocol is OAuth.
    /// </summary>
    public string? OAuthCode { get; init; }

    /// <summary>
    /// OpenID Connect ID token. Required when Protocol is OIDC.
    /// </summary>
    public string? IdToken { get; init; }

    /// <summary>
    /// JWT bearer token for JWT authentication. Required when Protocol is JWT.
    /// </summary>
    public string? BearerToken { get; init; }

    /// <summary>
    /// Additional protocol-specific parameters.
    /// </summary>
    public IDictionary<string, string> ExtraParameters { get; init; } = new Dictionary<string, string>();
}
