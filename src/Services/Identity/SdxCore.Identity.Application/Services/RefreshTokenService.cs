using SdxCore.Common.Security.Cryptography;
using SdxCore.Identity.Application.Abstractions.Security;
using SdxCore.Identity.Application.Abstractions.Services;
using SdxCore.Identity.Application.DTOs.Audit.Request;
using SdxCore.Identity.Application.DTOs.Auth.Response;
using SdxCore.Identity.Application.DTOs.Token.Request;
using SdxCore.Identity.Application.DTOs.Token.Response;
using SdxCore.Identity.Application.Enums;
using SdxCore.Identity.Application.Exceptions;
using SdxCore.Identity.Domain.Abstractions;
using SdxCore.Identity.Domain.Abstractions.Repositories;
using SdxCore.Identity.Domain.Entities;
using SdxCore.SharedKernel.Abstractions;
using System.Security.Claims;
using System.Security.Cryptography;

namespace SdxCore.Identity.Application.Services;

public class RefreshTokenService : IRefreshTokenService
{
    private readonly IIdentityUnitOfWork _unitOfWork;
    private readonly IAuditLoggerService _auditLoggerService;
    private readonly IUserContext _userContext;
    private readonly IRefreshTokenRepository _refreshTokenRepository;
    private readonly IUserRepository _userRepository;
    private readonly ITokenFactory _tokenFactory;

    public RefreshTokenService(
        IAuditLoggerService auditLoggerService,
        IUserContext userContext,
        IRefreshTokenRepository refreshTokenRepository,
        IUserRepository userRepository,
        ITokenFactory tokenFactory,
        IIdentityUnitOfWork unitOfWork)
    {
        _auditLoggerService = auditLoggerService ?? throw new ArgumentNullException(nameof(auditLoggerService));
        _userContext = userContext ?? throw new ArgumentNullException(nameof(userContext));
        _refreshTokenRepository = refreshTokenRepository ?? throw new ArgumentNullException(nameof(refreshTokenRepository));
        _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
        _tokenFactory = tokenFactory ?? throw new ArgumentNullException(nameof(tokenFactory));
        _unitOfWork = unitOfWork ?? throw new ArgumentNullException(nameof(unitOfWork));
    }

    // -- RefreshTokenAsync ------------------------------------
    // Owns a single SaveChangesAsync that commits both:
    //   1. New refresh token (staged by StageNewRefreshTokenAsync)
    //   2. Rotation of old token  (staged by StageRotateToken)
    public async Task<AuthenticationResponse> RefreshTokenAsync(
        RefreshTokenRequest refreshTokenRequest,
        CancellationToken ct = default)
    {
        ArgumentNullException.ThrowIfNull(refreshTokenRequest);

        if (string.IsNullOrWhiteSpace(refreshTokenRequest.RefreshToken))
            return new AuthenticationResponse
            {
                IsSuccess = false,
                ErrorCode = "INVALID_REFRESH_TOKEN",
                ErrorMessage = "Refresh token is required"
            };

        var existingToken = await ValidateAsync(refreshTokenRequest.RefreshToken, ct);
        if (existingToken is null)
            return new AuthenticationResponse
            {
                IsSuccess = false,
                ErrorCode = "INVALID_REFRESH_TOKEN",
                ErrorMessage = "Refresh token is invalid or expired"
            };

        var user = await _userRepository.GetByEmployeeIdAsync(existingToken.EmployeeId, ct)
            ?? throw new RecordNotFoundException(
                $"User with Id {existingToken.EmployeeId} not found.");

        var claims = BuildClaims(user);
        var newAccessToken = _tokenFactory.IssueToken(claims)
            ?? throw new InvalidOperationException("Token generation failed.");

        // Stage new refresh token — no SaveChangesAsync inside
        var refreshTokenResult = await StageNewRefreshTokenAsync(existingToken.EmployeeId, ct);

        // Stage rotation of old token — no SaveChangesAsync inside
        StageRotateToken(existingToken, refreshTokenResult.RawToken!);

        // -- Single commit: new token + rotation --------------
        await _unitOfWork.SaveChangesAsync(ct);

        newAccessToken.RefreshToken = refreshTokenResult.RawToken;
        newAccessToken.RefreshTokenExpiresAt = refreshTokenResult.ExpiresAt;

        await _auditLoggerService.LogAsync(new AuditEventRequest
        {
            EventType = "REFRESH_TOKEN_SUCCESS",
            Protocol = AuthProtocol.InHouse,
            Username = user.Username,
            EmployeeId = existingToken.EmployeeId,
            IpAddress = _userContext.IpAddress
        }, ct);

        return new AuthenticationResponse
        {
            IsSuccess = true,
            Token = newAccessToken,
            Claims = claims
        };
    }

    // -- CreateAsync ------------------------------------------
    // Stages a new RefreshToken entity only — does NOT call SaveChangesAsync.
    // Caller (AuthenticationService) owns the commit.
    public async Task<RefreshTokenResponse> CreateAsync(
        Guid employeeId,
        CancellationToken ct = default)
    {
        return await StageNewRefreshTokenAsync(employeeId, ct);
    }

    // -- RevokeRefreshTokenAsync ------------------------------
    // Standalone operation (logout) — owns its own commit.
    public async Task RevokeRefreshTokenAsync(
        string refreshToken,
        CancellationToken ct = default)
    {
        var hash = PasswordHasher.HashToken(refreshToken);
        var token = await _refreshTokenRepository.GetByHashAsync(hash, ct);
        if (token is null) return;

        token.RevokedAt = DateTime.UtcNow;
        token.RevokedByIp = _userContext.IpAddress;

        _refreshTokenRepository.Update(token);

        // Standalone logout — owns its commit
        await _unitOfWork.SaveChangesAsync(ct);
    }

    // -- GenerateRefreshToken ---------------------------------
    public string GenerateRefreshToken()
    {
        var bytes = new byte[64];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(bytes);
        return Convert.ToBase64String(bytes);
    }

    // -- Private helpers --------------------------------------

    /// <summary>
    /// Stages a new RefreshToken entity via AddAsync.
    /// Does NOT call SaveChangesAsync — caller owns the commit.
    /// </summary>
    private async Task<RefreshTokenResponse> StageNewRefreshTokenAsync(
        Guid employeeId,
        CancellationToken ct)
    {
        string rawToken = GenerateRefreshToken();

        var entity = new RefreshToken
        {
            Id = Guid.NewGuid(),
            EmployeeId = employeeId,
            HashToken = PasswordHasher.HashToken(rawToken),
            IsActive = true,
            CreatedBy = employeeId,
            LastUpdatedBy = employeeId,
            ExpiresAt = DateTime.UtcNow.AddDays(7),
            CreatedByIp = _userContext.IpAddress,
            UserAgent = _userContext.UserAgent,
            Device = _userContext.Device
        };

        await _refreshTokenRepository.AddAsync(entity, ct);

        return new RefreshTokenResponse
        {
            Id = entity.Id,
            EmployeeId = entity.EmployeeId,
            RawToken = rawToken,
            HashToken = entity.HashToken,
            ExpiresAt = entity.ExpiresAt
        };
    }

    /// <summary>
    /// Stages rotation of an existing token via Update.
    /// Does NOT call SaveChangesAsync — caller owns the commit.
    /// </summary>
    private void StageRotateToken(
        RefreshToken existingToken,
        string newRawToken)
    {
        existingToken.RevokedAt = DateTime.UtcNow;
        existingToken.RevokedByIp = _userContext.IpAddress;
        existingToken.ReplacedByHashToken = PasswordHasher.HashToken(newRawToken);

        _refreshTokenRepository.Update(existingToken);
    }

    private async Task<RefreshToken?> ValidateAsync(
        string refreshToken,
        CancellationToken ct)
    {
        var hash = PasswordHasher.HashToken(refreshToken);
        if (hash is null) return null;

        var entity = await _refreshTokenRepository.GetByHashAsync(hash, ct);
        if (entity is null) return null;
        if (entity.RevokedAt is not null) return null;
        if (entity.ExpiresAt <= DateTime.UtcNow) return null;

        return entity;
    }

    private static IReadOnlyList<Claim> BuildClaims(User user) =>
    [
        new("sub",      user.EmployeeId.ToString()),
        new("username", user.Username),
        new("email",    user.Email)
    ];
}