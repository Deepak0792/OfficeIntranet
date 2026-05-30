using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;
using SdxCore.Identity.Domain.DTOs.Request;
using SdxCore.Identity.Domain.DTOs.Response;
using SdxCore.Identity.Application.Interfaces;
using SdxCore.Identity.Application.Interfaces.Providers;

namespace SdxCore.Identity.Application.Providers;

/// <summary>
/// OpenID Connect authentication provider.
/// Validates ID tokens from external OIDC identity providers.
/// </summary>
/// <remarks>
/// This provider validates OIDC ID tokens according to requirement 3.3:
/// - Validates the token signature against the configured authority
/// - Validates token claims (issuer, audience, expiry)
/// - Extracts user claims from the validated token
/// 
/// Configuration is read from the "Oidc" section in appsettings.json (Requirement 11.11).
/// </remarks>
public sealed class OidcProvider : IAuthenticationProvider
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<OidcProvider> _logger;
    private readonly JwtSecurityTokenHandler _tokenHandler;
    private readonly ConfigurationManager<OpenIdConnectConfiguration> _configurationManager;

    // Configuration keys
    private const string AuthorityKey = "Oidc:Authority";
    private const string ClientIdKey = "Oidc:ClientId";
    private const string ClientSecretKey = "Oidc:ClientSecret";

    /// <summary>
    /// Initializes a new instance of the <see cref="OidcProvider"/> class.
    /// </summary>
    /// <param name="configuration">Application configuration.</param>
    /// <param name="logger">Logger instance.</param>
    public OidcProvider(
        IConfiguration configuration,
        ILogger<OidcProvider> logger)
    {
        _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        _tokenHandler = new JwtSecurityTokenHandler();

        // Validate required configuration
        string? authority = _configuration[AuthorityKey];
        if (string.IsNullOrWhiteSpace(authority))
        {
            throw new InvalidOperationException($"OIDC configuration is missing required key: {AuthorityKey}");
        }

        // Initialize OIDC configuration manager for automatic discovery
        // This will fetch the .well-known/openid-configuration document
        string metadataAddress = authority.TrimEnd('/') + "/.well-known/openid-configuration";
        _configurationManager = new ConfigurationManager<OpenIdConnectConfiguration>(
            metadataAddress,
            new OpenIdConnectConfigurationRetriever(),
            new HttpDocumentRetriever());
    }

    /// <inheritdoc />
    public AuthProtocol Protocol => AuthProtocol.Oidc;

    /// <inheritdoc />
    public async Task<ProviderResponse> AuthenticateAsync(AuthenticationRequest request, CancellationToken ct = default)
    {
        // 1. Validate input (Requirement 7.5)
        if (string.IsNullOrWhiteSpace(request.IdToken))
        {
            _logger.LogWarning("Authentication attempt with missing ID token");
            return Fail("ID token is required.");
        }

        try
        {
            // 2. Read configuration
            string? authority = _configuration[AuthorityKey];
            string? clientId = _configuration[ClientIdKey];

            if (string.IsNullOrWhiteSpace(authority))
            {
                _logger.LogError("OIDC Authority is not configured");
                return Fail("OIDC provider is not properly configured.");
            }

            if (string.IsNullOrWhiteSpace(clientId))
            {
                _logger.LogError("OIDC ClientId is not configured");
                return Fail("OIDC provider is not properly configured.");
            }

            // 3. Retrieve OIDC configuration (signing keys, issuer, etc.)
            OpenIdConnectConfiguration oidcConfig;
            try
            {
                oidcConfig = await _configurationManager.GetConfigurationAsync(ct);
            }
            catch (Exception ex)
            {
                // Requirement 9.1, 9.2: External IdP unreachable
                _logger.LogError(ex, "Failed to retrieve OIDC configuration from authority: {Authority}", authority);
                return Fail("OIDC provider is unavailable.");
            }

            // 4. Configure token validation parameters (Requirement 3.3)
            var validationParameters = new TokenValidationParameters
            {
                // Validate the token signature using keys from the OIDC discovery document
                ValidateIssuerSigningKey = true,
                IssuerSigningKeys = oidcConfig.SigningKeys,

                // Validate the issuer matches the authority
                ValidateIssuer = true,
                ValidIssuer = oidcConfig.Issuer,

                // Validate the audience matches our client ID
                ValidateAudience = true,
                ValidAudience = clientId,

                // Validate token expiry
                ValidateLifetime = true,
                ClockSkew = TimeSpan.FromMinutes(5), // Allow 5 minutes clock skew

                // Require expiration time
                RequireExpirationTime = true,

                // Require signed tokens
                RequireSignedTokens = true
            };

            // 5. Validate the ID token (Requirement 3.3)
            ClaimsPrincipal principal;
            SecurityToken validatedToken;

            try
            {
                principal = _tokenHandler.ValidateToken(request.IdToken, validationParameters, out validatedToken);
            }
            catch (SecurityTokenExpiredException ex)
            {
                _logger.LogWarning(ex, "ID token has expired");
                return Fail("ID token has expired.");
            }
            catch (SecurityTokenInvalidSignatureException ex)
            {
                _logger.LogWarning(ex, "ID token signature validation failed");
                return Fail("ID token signature is invalid.");
            }
            catch (SecurityTokenInvalidAudienceException ex)
            {
                _logger.LogWarning(ex, "ID token audience validation failed");
                return Fail("ID token audience is invalid.");
            }
            catch (SecurityTokenInvalidIssuerException ex)
            {
                _logger.LogWarning(ex, "ID token issuer validation failed");
                return Fail("ID token issuer is invalid.");
            }
            catch (SecurityTokenException ex)
            {
                _logger.LogWarning(ex, "ID token validation failed");
                return Fail($"ID token validation failed: {ex.Message}");
            }

            // 6. Extract claims from the validated token (Requirement 17.5)
            var claims = principal.Claims.ToList();

            // Ensure we have at least a subject claim
            var subjectClaim = claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier || c.Type == "sub");
            if (subjectClaim == null)
            {
                _logger.LogWarning("ID token does not contain a subject identifier");
                return Fail("ID token is missing required subject identifier.");
            }

            _logger.LogInformation("Successfully validated OIDC ID token for subject: {Subject}", subjectClaim.Value);

            return new ProviderResponse { IsSuccess = true, Claims = claims };
        }
        catch (Exception ex)
        {
            // Requirement 9.3: Catch exceptions and return failure result
            _logger.LogError(ex, "Error processing OIDC ID token");
            return Fail($"OIDC authentication failed: {ex.Message}");
        }
    }

    /// <summary>
    /// Builds a failure result with the specified reason.
    /// </summary>
    /// <param name="reason">Failure reason.</param>
    /// <returns>Provider result indicating failure.</returns>
    private static ProviderResponse Fail(string reason)
    {
        return new ProviderResponse
        {
            IsSuccess = false,
            FailureReason = reason
        };
    }
}
