using SdxCore.Identity.Domain.DTOs;
using SdxCore.Identity.Domain.Entities;

namespace SdxCore.Identity.Domain.Interfaces.Services;
public interface IRefreshTokenService
{
    string GenerateRefreshToken();

    Task<RefreshTokenResult> CreateAsync(Guid userId, string? ip, string? userAgent, string? device, CancellationToken ct = default);

    Task<AuthenticationResult> RefreshTokenAsync(RefreshTokenRequest refreshTokenRequest, CancellationToken ct = default);
}