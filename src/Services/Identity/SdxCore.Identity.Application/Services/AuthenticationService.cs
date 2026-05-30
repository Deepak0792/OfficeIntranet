using Microsoft.Extensions.Logging;
using SdxCore.Common.Interfaces.Contexts;
using SdxCore.Identity.Domain.DTOs;
using SdxCore.Identity.Domain.DTOs.Request;
using SdxCore.Identity.Domain.DTOs.Response;
using SdxCore.Identity.Application.Interfaces;
using SdxCore.Identity.Application.Exceptions;
using SdxCore.Identity.Application.Interfaces.Providers;
using SdxCore.Identity.Application.Interfaces.Security;
using SdxCore.Identity.Application.Interfaces.Services;
using System.Security.Claims;

namespace SdxCore.Identity.Application.Services;

/// <summary>
/// Central authentication service that orchestrates authentication operations.
/// Resolves providers, delegates authentication, issues tokens, and records audit events.
/// </summary>
public sealed class AuthenticationService : IAuthenticationService
{
    private readonly IRequestContext _requestContext;
    private readonly IProviderRegistry _providerRegistry;
    private readonly ITokenFactory _tokenFactory;
    private readonly IAuditLoggerService _auditLoggerService;
    private readonly ILogger<AuthenticationService> _logger;
    private readonly IRefreshTokenService _refreshTokenService;

    public AuthenticationService(
        IRequestContext requestContext,
        IProviderRegistry providerRegistry,
        ITokenFactory tokenFactory,
        IAuditLoggerService auditLoggerService,
        IRefreshTokenService refreshTokenService,
        ILogger<AuthenticationService> logger)
    {
        _requestContext = requestContext ?? throw new ArgumentNullException(nameof(requestContext));
        _providerRegistry = providerRegistry ?? throw new ArgumentNullException(nameof(providerRegistry));
        _tokenFactory = tokenFactory ?? throw new ArgumentNullException(nameof(tokenFactory));
        _auditLoggerService = auditLoggerService ?? throw new ArgumentNullException(nameof(auditLoggerService));
        _refreshTokenService = refreshTokenService ?? throw new ArgumentNullException(nameof(refreshTokenService));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Authenticates a user based on the provided request.
    /// </summary>
    /// <param name="request">Authentication request containing credentials and protocol-specific parameters.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>Authentication result containing success status, token, and claims.</returns>
    public async Task<AuthenticationResponse> AuthenticateAsync(AuthenticationRequest request, CancellationToken ct = default)
    {
        if (request is null)
        {
            throw new ArgumentNullException(nameof(request));
        }

        IAuthenticationProvider? provider = null;
        AuthProtocol protocol = AuthProtocol.InHouse; // Default for logging purposes

        try
        {
            // 1. Resolve provider from configuration
            provider = _providerRegistry.ResolveFromConfiguration();
            protocol = provider.Protocol;

            _logger.LogDebug("Resolved authentication provider: {Protocol}", protocol);

            // 2. Validate request based on protocol
            ValidateRequest(request, protocol);

            // 3. Delegate authentication to provider
            ProviderResponse providerResult = await provider.AuthenticateAsync(request, ct);

            // 4. Handle authentication failure
            if (!providerResult.IsSuccess)
            {
                _logger.LogWarning(
                    "Authentication failed for user {Username} using protocol {Protocol}: {Reason}",
                    request.Username ?? "unknown",
                    protocol,
                    providerResult.FailureReason);

                // Log audit event for failure
                await _auditLoggerService.LogAsync(new AuditEventRequest
                {
                    EventType = "LOGIN_FAILURE",
                    Protocol = protocol,
                    Username = request.Username,
                    FailureReason = providerResult.FailureReason,
                }, ct);

                return new AuthenticationResponse
                {
                    IsSuccess = false,
                    ErrorCode = "AUTH_FAILED",
                    ErrorMessage = providerResult.FailureReason ?? "Authentication failed"
                };
            }

            // 5. Issue token from claims
            AuthToken token = _tokenFactory.IssueToken(providerResult.Claims);

            if (token is null)
                throw new ArgumentNullException("Token Generation failed");

            int employeeId = ExtractSubjectFromClaims(providerResult.Claims);

            if (employeeId == 0)
            {
                throw new ArgumentException("EmployeeId is 0");
            }

            _logger.LogInformation(
               "Authentication successful for user {Username} using protocol {Protocol}",
               request.Username ?? ExtractSubjectFromClaims(providerResult.Claims).ToString(),
            protocol);

            // 5.1 Generate refresh token
            // Store new refresh token
            var refreshTokenResult =
                await _refreshTokenService.CreateAsync(
                    employeeId,
                    ct);

            token.RefreshToken = refreshTokenResult.RawToken;
            token.RefreshTokenExpiresAt = refreshTokenResult.ExpiresAt;

            // 6. Log audit event for success
            await _auditLoggerService.LogAsync(new AuditEventRequest
            {
                EventType = "LOGIN_SUCCESS",
                Protocol = protocol,
                Username = request.Username,
                EmployeeId = employeeId
            }, ct);

            // 7. Return successful result
            return new AuthenticationResponse
            {
                IsSuccess = true,
                Token = token,
                Claims = providerResult.Claims
            };
        }
        catch (ConfigurationException ex)
        {
            _logger.LogError(ex, "Configuration error during authentication");

            // Log audit event for configuration error
            await _auditLoggerService.LogAsync(new AuditEventRequest
            {
                EventType = "LOGIN_FAILURE",
                Protocol = protocol,
                Username = request.Username,
                FailureReason = "Configuration error"
            }, ct);

            return new AuthenticationResponse
            {
                IsSuccess = false,
                ErrorCode = "CONFIGURATION_ERROR",
                ErrorMessage = "Authentication service is not properly configured"
            };
        }
        catch (ProviderNotFoundException ex)
        {
            _logger.LogError(ex, "Provider not found during authentication");

            // Log audit event for provider not found
            await _auditLoggerService.LogAsync(new AuditEventRequest
            {
                EventType = "LOGIN_FAILURE",
                Protocol = protocol,
                Username = request.Username,
                FailureReason = "Provider not found"
            }, ct);

            return new AuthenticationResponse
            {
                IsSuccess = false,
                ErrorCode = "PROVIDER_NOT_FOUND",
                ErrorMessage = "Authentication provider is not available"
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error during authentication");

            // Log audit event for unexpected error
            await _auditLoggerService.LogAsync(new AuditEventRequest
            {
                EventType = "LOGIN_FAILURE",
                Protocol = protocol,
                Username = request.Username,
                FailureReason = "Internal error"
            }, ct);


            return new AuthenticationResponse
            {
                IsSuccess = false,
                ErrorCode = "INTERNAL_ERROR",
                ErrorMessage = "An unexpected error occurred during authentication"
            };
        }
    }

    /// <summary>
    /// Validates a JWT token.
    /// </summary>
    /// <param name="token">JWT token to validate.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>True if the token is valid, not expired, and not revoked; otherwise false.</returns>
    public Task<bool> ValidateTokenAsync(string token, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            _logger.LogWarning("Token validation failed: token is null or empty");
            return Task.FromResult(false);
        }

        try
        {
            ClaimsPrincipal? principal = _tokenFactory.ValidateToken(token);
            bool isValid = principal is not null;

            if (isValid)
            {
                _logger.LogDebug("Token validation successful");
            }
            else
            {
                _logger.LogWarning("Token validation failed");
            }

            return Task.FromResult(isValid);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during token validation");
            return Task.FromResult(false);
        }
    }


    /// <summary>
    /// Revokes a JWT token before its expiration.
    /// </summary>
    /// <param name="token">JWT token to revoke.</param>
    /// <param name="ct">Cancellation token.</param>
    public async Task RevokeTokenAsync(RevokeTokenRequest request, CancellationToken ct = default)
    {
        if (request == null ||
           string.IsNullOrWhiteSpace(request.Token) ||
           string.IsNullOrWhiteSpace(request.RefreshToken))
        {
            throw new ArgumentNullException("Token cannot be null or empty", nameof(request));
        }

        try
        {
            _tokenFactory.RevokeToken(request.Token);

            if (!string.IsNullOrEmpty(request.RefreshToken))
            {
                await _refreshTokenService.RevokeRefreshTokenAsync(request.RefreshToken);
            }
            _logger.LogInformation("Token revoked successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during token revocation");
            throw;
        }
    }

    /// <summary>
    /// Validates the authentication request based on the protocol.
    /// </summary>
    private void ValidateRequest(AuthenticationRequest request, AuthProtocol protocol)
    {
        switch (protocol)
        {
            case AuthProtocol.InHouse:
                if (string.IsNullOrWhiteSpace(request.Username))
                    throw new ArgumentNullException("Username is required for InHouse authentication", nameof(request));
                if (string.IsNullOrWhiteSpace(request.Password))
                    throw new ArgumentNullException("Password is required for InHouse authentication", nameof(request));
                break;

            case AuthProtocol.Saml:
                if (string.IsNullOrWhiteSpace(request.SamlAssertion))
                    throw new ArgumentNullException("SAML assertion is required for SAML authentication", nameof(request));
                break;

            case AuthProtocol.OAuth:
                if (string.IsNullOrWhiteSpace(request.OAuthCode))
                    throw new ArgumentNullException("OAuth code is required for OAuth authentication", nameof(request));
                break;

            case AuthProtocol.Oidc:
                if (string.IsNullOrWhiteSpace(request.IdToken))
                    throw new ArgumentNullException("ID token is required for OIDC authentication", nameof(request));
                break;

            case AuthProtocol.Jwt:
                if (string.IsNullOrWhiteSpace(request.BearerToken))
                    throw new ArgumentNullException("Bearer token is required for JWT authentication", nameof(request));
                break;

            case AuthProtocol.Ldap:
                if (string.IsNullOrWhiteSpace(request.Username))
                    throw new ArgumentNullException("Username is required for LDAP authentication", nameof(request));
                if (string.IsNullOrWhiteSpace(request.Password))
                    throw new ArgumentNullException("Password is required for LDAP authentication", nameof(request));
                break;

            default:
                throw new ArgumentNullException($"Unsupported authentication protocol: {protocol}", nameof(protocol));
        }
    }

    /// <summary>
    /// Extracts the subject (user ID) from claims.
    /// </summary>
    private int ExtractSubjectFromClaims(IReadOnlyList<Claim> claims)
    {
        return Convert.ToInt32(claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier || c.Type == "sub")?.Value);
    }
}
