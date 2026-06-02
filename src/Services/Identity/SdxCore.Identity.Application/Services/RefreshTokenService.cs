using SdxCore.Common.Security;
using SdxCore.Identity.Application.Contracts.Security;
using SdxCore.Identity.Application.Contracts.Services;
using SdxCore.Identity.Application.Enums;
using SdxCore.Identity.Application.Exceptions;
using SdxCore.Identity.Domain.DTOs.Request;
using SdxCore.Identity.Domain.DTOs.Response;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Repositories;
using SdxCore.SharedKernel.Contracts;
using System.Security.Claims;
using System.Security.Cryptography;

namespace SdxCore.Identity.Application.Services;
public class RefreshTokenService : IRefreshTokenService
{
    private readonly IAuditLoggerService _auditLoggerService;
    private readonly IRequestContext _requestContext;
    private readonly IRefreshTokenRepository _refreshTokenRepository;
    private readonly IUserRepository _userRepository;
    private readonly ITokenFactory _tokenFactory;

    public RefreshTokenService(
        IAuditLoggerService auditLoggerService,
        IRequestContext requestContext,
        IRefreshTokenRepository refreshTokenRepository,
        IUserRepository userRepository,
        ITokenFactory tokenFactory)
    {
        _auditLoggerService = auditLoggerService ?? throw new ArgumentNullException(nameof(requestContext));
        _requestContext = requestContext ?? throw new ArgumentNullException(nameof(requestContext));
        _refreshTokenRepository = refreshTokenRepository ?? throw new ArgumentNullException(nameof(refreshTokenRepository));
        _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
        _tokenFactory = tokenFactory ?? throw new ArgumentNullException(nameof(tokenFactory)); ;
    }

    public async Task<AuthenticationResponse> RefreshTokenAsync(RefreshTokenRequest refreshTokenRequest, CancellationToken ct = default)
    {
        if (refreshTokenRequest is null)
        {
            throw new ArgumentNullException(nameof(refreshTokenRequest));
        }

        if (string.IsNullOrWhiteSpace(refreshTokenRequest.RefreshToken))
        {
            return new AuthenticationResponse
            {
                IsSuccess = false,
                ErrorCode = "INVALID_REFRESH_TOKEN",
                ErrorMessage = "Refresh token is required"
            };
        }

        var existingToken = await ValidateAsync(refreshTokenRequest.RefreshToken, ct);

        if (existingToken is null)
        {
            return new AuthenticationResponse
            {
                IsSuccess = false,
                ErrorCode = "INVALID_REFRESH_TOKEN",
                ErrorMessage = "Refresh token is invalid or expired"
            };
        }

        // Build claims (IMPORTANT: ideally load user from DB here)
        User? user = await _userRepository.GetByIdAsync(existingToken.EmployeeId, ct);

        if (user is null)
        {
            throw new RecordNotFoundException($"User with Id {existingToken.EmployeeId} not found.");
        }

        var claims = BuildClaims(user);

        // Issue new access token
        var newAccessToken = _tokenFactory.IssueToken(claims);

        if (newAccessToken is null)
            throw new ArgumentNullException("Token Generation failed");

        // Generate new refresh token
        // Store new refresh token
        var refreshTokenResult =
            await CreateAsync(
                existingToken.EmployeeId,
                ct);

        if (refreshTokenResult.RawToken is null)
            throw new ArgumentNullException("Refresh Token is null");

        newAccessToken.RefreshToken = refreshTokenResult.RawToken;
        newAccessToken.RefreshTokenExpiresAt = refreshTokenResult.ExpiresAt;

        // Rotate old token
        await RotateAsync(
            existingToken,
            refreshTokenResult.RawToken,
            _requestContext.IpAddress,
            ct);

        await _auditLoggerService.LogAsync(new AuditEventRequest
        {
            EventType = "REFRESH_TOKEN_SUCCESS",
            Protocol = AuthProtocol.InHouse,
            Username = user.Username,
            EmployeeId = existingToken.EmployeeId
        }, ct);

        return new AuthenticationResponse
        {
            IsSuccess = true,
            Token = newAccessToken,
            Claims = claims
        };
    }

    /// <summary>
    /// Generate raw refresh token
    /// </summary>
    /// <returns>return the refresh token</returns>
    public string GenerateRefreshToken()
    {
        var bytes = new byte[64];

        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(bytes);

        return Convert.ToBase64String(bytes);
    }

    /// <summary>
    /// Create new refresh token entry
    /// </summary>
    /// <param name="userId"></param>
    /// <param name="ipAddress"></param>
    /// <param name="userAgent"></param>
    /// <param name="rawRefreshToken"></param>
    /// <param name="ct"></param>
    /// <returns></returns>
    public async Task<RefreshTokenResponse> CreateAsync(
        int employeeId,
        CancellationToken ct = default)
    {
        string rawRefreshToken = GenerateRefreshToken();

        var entity = new RefreshToken
        {
            EmployeeId = employeeId,
            HashToken = PasswordHasher.HashToken(rawRefreshToken),
            CreatedBy = employeeId,
            LastUpdatedBy = employeeId,
            ExpiresAt = DateTime.UtcNow.AddDays(7),
            CreatedByIp = _requestContext.IpAddress,
            UserAgent = _requestContext.UserAgent,
            Device = _requestContext.Device
        };

        await _refreshTokenRepository.AddAsync(entity, ct);
        await _refreshTokenRepository.SaveChangesAsync(ct);
       
        var result = new RefreshTokenResponse
        {
            Id = entity.Id,
            EmployeeId = entity.EmployeeId,
            RawToken = rawRefreshToken,
            HashToken = entity.HashToken,
            ExpiresAt = entity.ExpiresAt
        };

        return result;
    }
    /// <summary>
    /// Validate refresh token
    /// </summary>
    /// <param name="refreshToken"></param>
    /// <param name="ct"></param>
    /// <returns></returns>
    private async Task<RefreshToken?> ValidateAsync(string refreshToken, CancellationToken ct = default)
    {
        var hash = PasswordHasher.HashToken(refreshToken);

        if (hash is null)
            return null;

        var entity = await _refreshTokenRepository.GetByHashAsync(hash, ct);

        if (entity == null)
            return null;

        if (entity.RevokedAt != null)
            return null;

        if (entity.ExpiresAt <= DateTime.UtcNow)
            return null;

        return entity;
    }

    /// <summary>
    /// Rotate refresh token
    /// </summary>
    /// <param name="existingToken"></param>
    /// <param name="rawRefreshToken"></param>
    /// <param name="ipAddress"></param>
    /// <param name="ct"></param>
    /// <returns></returns>
    private async Task RotateAsync(
        RefreshToken existingToken,
        string rawRefreshToken,
        string? ipAddress,
        CancellationToken ct = default)
    {
        existingToken.RevokedAt = DateTime.UtcNow;
        existingToken.RevokedByIp = ipAddress;
        existingToken.ReplacedByHashToken = PasswordHasher.HashToken(rawRefreshToken);

        _refreshTokenRepository.Update(existingToken);
        await _refreshTokenRepository.SaveChangesAsync(ct);
    }

    /// <summary>
    /// Revoke token (logout)
    /// </summary>
    /// <param name="refreshToken"></param>
    /// <param name="ipAddress"></param>
    /// <param name="ct"></param>
    /// <returns></returns>
    public async Task RevokeRefreshTokenAsync(string refreshToken, CancellationToken ct = default)
    {
        var hash = PasswordHasher.HashToken(refreshToken);

        var token = await _refreshTokenRepository.GetByHashAsync(hash, ct);

        if (token == null)
            return;

        token.RevokedAt = DateTime.UtcNow;
        token.RevokedByIp = _requestContext.IpAddress;

        _refreshTokenRepository.Update(token);
        await _refreshTokenRepository.SaveChangesAsync(ct);
    }

    private static IReadOnlyList<Claim> BuildClaims(User user)
    {
        return new List<Claim>
        {
            new ("sub", user.EmployeeId.ToString()),
            new ("username", user.Username),
            new ("email", user.Email)
        };
    }
}