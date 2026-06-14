using FluentValidation;
using Microsoft.Extensions.Logging;
using SdxCore.Identity.Application.Abstractions.Providers;
using SdxCore.Identity.Application.Abstractions.Security;
using SdxCore.Identity.Application.Abstractions.Services;
using SdxCore.Identity.Application.DTOs.Audit.Request;
using SdxCore.Identity.Application.DTOs.Auth.Request;
using SdxCore.Identity.Application.DTOs.Auth.Response;
using SdxCore.Identity.Application.DTOs.Token.Request;
using SdxCore.Identity.Application.Enums;
using SdxCore.Identity.Application.Exceptions;
using SdxCore.Identity.Domain.Abstractions;
using SdxCore.SharedKernel.Abstractions;
using System.Security.Claims;

namespace SdxCore.Identity.Application.Services;

/// <summary>
/// Central authentication service that orchestrates authentication operations.
/// 
/// Commit ownership:
///   - InHouseProvider.AuthenticateAsync owns its own commit for
///     failed-attempt tracking and successful login updates. This is
///     intentional — those writes must be persisted immediately,
///     independent of token issuance.
///   - AuthenticationService owns ONE commit for the refresh token
///     staged by RefreshTokenService.CreateAsync.
/// </summary>
public sealed class AuthenticationService : IAuthenticationService
{
    private readonly IUserContext _userContext;
    private readonly IProviderRegistry _providerRegistry;
    private readonly ITokenFactory _tokenFactory;
    private readonly IAuditLoggerService _auditLoggerService;
    private readonly IRefreshTokenService _refreshTokenService;
    private readonly IIdentityUnitOfWork _unitOfWork;
    private readonly IValidator<AuthenticationRequest> _requestValidator;
    private readonly ILogger<AuthenticationService> _logger;

    public AuthenticationService(
        IUserContext userContext,
        IProviderRegistry providerRegistry,
        ITokenFactory tokenFactory,
        IAuditLoggerService auditLoggerService,
        IRefreshTokenService refreshTokenService,
        IIdentityUnitOfWork unitOfWork,
        IValidator<AuthenticationRequest> requestValidator,
        ILogger<AuthenticationService> logger)
    {
        _userContext = userContext ?? throw new ArgumentNullException(nameof(userContext));
        _providerRegistry = providerRegistry ?? throw new ArgumentNullException(nameof(providerRegistry));
        _tokenFactory = tokenFactory ?? throw new ArgumentNullException(nameof(tokenFactory));
        _auditLoggerService = auditLoggerService ?? throw new ArgumentNullException(nameof(auditLoggerService));
        _refreshTokenService = refreshTokenService ?? throw new ArgumentNullException(nameof(refreshTokenService));
        _unitOfWork = unitOfWork ?? throw new ArgumentNullException(nameof(unitOfWork));
        _requestValidator = requestValidator ?? throw new ArgumentNullException(nameof(requestValidator));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    // -- AuthenticateAsync ------------------------------------
    // Commit flow:
    //   1. provider.AuthenticateAsync()          - InHouseProvider owns its commit
    //   2. _refreshTokenService.CreateAsync()    - stages only, no commit
    //   3. _unitOfWork.SaveChangesAsync()        - single commit for refresh token
    public async Task<AuthenticationResponse> AuthenticateAsync(
        AuthenticationRequest request,
        CancellationToken ct = default)
    {
        ArgumentNullException.ThrowIfNull(request);
        var protocol = AuthProtocol.InHouse;

        try
        {
            var provider = _providerRegistry.ResolveFromConfiguration();
            protocol = provider.Protocol;

            _logger.LogDebug("Resolved authentication provider: {Protocol}", protocol);

            _requestValidator.ValidateAndThrow(request);

            ProviderResponse providerResult = await provider.AuthenticateAsync(request, ct);

            if (!providerResult.IsSuccess)
            {
                _logger.LogWarning(
                    "Authentication failed for user {Username} via {Protocol}: {Reason} from {IpAddress}",
                    request.Username ?? "unknown",
                    protocol,
                    providerResult.FailureReason,
                    _userContext.IpAddress);

                await _auditLoggerService.LogAsync(new AuditEventRequest
                {
                    EventType = "LOGIN_FAILURE",
                    Protocol = protocol,
                    Username = request.Username,
                    FailureReason = providerResult.FailureReason,
                    IpAddress = _userContext.IpAddress
                }, ct);

                return new AuthenticationResponse
                {
                    IsSuccess = false,
                    ErrorCode = "AUTH_FAILED",
                    ErrorMessage = providerResult.FailureReason ?? "Authentication failed"
                };
            }

            var token = _tokenFactory.IssueToken(providerResult.Claims)
                ?? throw new InvalidOperationException("Token generation failed.");

            var employeeId = ExtractSubjectFromClaims(providerResult.Claims);
            if (employeeId == Guid.Empty)
                throw new ArgumentException("EmployeeId cannot be empty.");

            // Stage new refresh token - CreateAsync does NOT call SaveChangesAsync
            var refreshTokenResult = await _refreshTokenService.CreateAsync(employeeId, ct);

            // -- Single commit for refresh token --------------
            await _unitOfWork.SaveChangesAsync(ct);

            token.RefreshToken = refreshTokenResult.RawToken;
            token.RefreshTokenExpiresAt = refreshTokenResult.ExpiresAt;

            _logger.LogInformation(
                "Authentication successful for user {Username} via {Protocol}",
                request.Username ?? employeeId.ToString(),
                protocol);

            await _auditLoggerService.LogAsync(new AuditEventRequest
            {
                EventType = "LOGIN_SUCCESS",
                Protocol = protocol,
                Username = request.Username,
                EmployeeId = employeeId,
                IpAddress = _userContext.IpAddress
            }, ct);

            return new AuthenticationResponse
            {
                IsSuccess = true,
                Token = token,
                Claims = providerResult.Claims
            };
        }
        catch (ConfigurationException ex)
        {
            _logger.LogError(ex, "Configuration error during authentication.");

            await _auditLoggerService.LogAsync(new AuditEventRequest
            {
                EventType = "LOGIN_FAILURE",
                Protocol = protocol,
                Username = request.Username,
                FailureReason = "Configuration error",
                IpAddress = _userContext.IpAddress
            }, ct);

            return new AuthenticationResponse
            {
                IsSuccess = false,
                ErrorCode = "CONFIGURATION_ERROR",
                ErrorMessage = "Authentication service is not properly configured."
            };
        }
        catch (ProviderNotFoundException ex)
        {
            _logger.LogError(ex, "Provider not found during authentication.");

            await _auditLoggerService.LogAsync(new AuditEventRequest
            {
                EventType = "LOGIN_FAILURE",
                Protocol = protocol,
                Username = request.Username,
                FailureReason = "Provider not found",
                IpAddress = _userContext.IpAddress
            }, ct);

            return new AuthenticationResponse
            {
                IsSuccess = false,
                ErrorCode = "PROVIDER_NOT_FOUND",
                ErrorMessage = "Authentication provider is not available."
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error during authentication.");

            await _auditLoggerService.LogAsync(new AuditEventRequest
            {
                EventType = "LOGIN_FAILURE",
                Protocol = protocol,
                Username = request.Username,
                FailureReason = "Internal error",
                IpAddress = _userContext.IpAddress
            }, ct);

            return new AuthenticationResponse
            {
                IsSuccess = false,
                ErrorCode = "INTERNAL_ERROR",
                ErrorMessage = "An unexpected error occurred during authentication."
            };
        }
    }

    // -- ValidateTokenAsync -----------------------------------
    // Read-only — no persistence, no commit needed.
    public Task<bool> ValidateTokenAsync(string token, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            _logger.LogWarning("Token validation failed: token is null or empty.");
            return Task.FromResult(false);
        }

        try
        {
            ClaimsPrincipal? principal = _tokenFactory.ValidateToken(token);
            bool isValid = principal is not null;

            if (isValid)
                _logger.LogDebug("Token validation successful.");
            else
                _logger.LogWarning("Token validation failed.");

            return Task.FromResult(isValid);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during token validation.");
            return Task.FromResult(false);
        }
    }

    // -- RevokeTokenAsync -------------------------------------
    // Delegates to RefreshTokenService.RevokeRefreshTokenAsync which
    // owns its own commit (standalone logout operation).
    public async Task RevokeTokenAsync(RevokeTokenRequest request, CancellationToken ct = default)
    {
        if (request is null ||
            string.IsNullOrWhiteSpace(request.Token) ||
            string.IsNullOrWhiteSpace(request.RefreshToken))
        {
            throw new ArgumentNullException(nameof(request), "Token and RefreshToken are required.");
        }

        try
        {
            _tokenFactory.RevokeToken(request.Token);

            if (!string.IsNullOrEmpty(request.RefreshToken))
            {
                // RevokeRefreshTokenAsync owns its own commit
                await _refreshTokenService.RevokeRefreshTokenAsync(request.RefreshToken, ct);
            }

            _logger.LogInformation("Token revoked successfully.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error during token revocation.");
            throw;
        }
    }

    // -- Private helpers --------------------------------------

    private static Guid ExtractSubjectFromClaims(IReadOnlyList<Claim> claims)
    {
        var subjectValue = claims
            .FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier || c.Type == "sub")
            ?.Value;

        if (!Guid.TryParse(subjectValue, out var subjectId))
            throw new InvalidOperationException(
                "Subject claim is missing or is not a valid GUID.");

        return subjectId;
    }
}