using SdxCore.Identity.Domain.DTOs.Request;
using SdxCore.Identity.Domain.DTOs.Response;
using SdxCore.Identity.Domain.Entities;

namespace SdxCore.Identity.Domain.Interfaces.Services;
public interface IRefreshTokenService
{
    string GenerateRefreshToken();

    Task<RefreshTokenResponse> CreateAsync(Guid userId, CancellationToken ct = default);

    Task<AuthenticationResponse> RefreshTokenAsync(RefreshTokenRequest refreshTokenRequest, CancellationToken ct = default);

    Task RevokeRefreshTokenAsync(string refreshToken, CancellationToken ct = default);
}