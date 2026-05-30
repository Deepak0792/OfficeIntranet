namespace SdxCore.Identity.Application.Interfaces;

/// <summary>
/// Defines the supported authentication protocols.
/// </summary>
public enum AuthProtocol
{
    /// <summary>
    /// Built-in username/password authentication backed by SQL Server.
    /// </summary>
    InHouse,

    /// <summary>
    /// SAML 2.0 authentication protocol.
    /// </summary>
    Saml,

    /// <summary>
    /// OAuth 2.0 authentication protocol.
    /// </summary>
    OAuth,

    /// <summary>
    /// OpenID Connect authentication protocol.
    /// </summary>
    Oidc,

    /// <summary>
    /// JWT bearer token validation.
    /// </summary>
    Jwt,

    /// <summary>
    /// LDAP / Active Directory authentication.
    /// </summary>
    Ldap
}
