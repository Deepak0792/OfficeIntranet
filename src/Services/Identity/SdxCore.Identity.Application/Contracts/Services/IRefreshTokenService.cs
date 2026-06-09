using SdxCore.Identity.Domain.DTOs.Request;
using SdxCore.Identity.Domain.DTOs.Response;
using SdxCore.Identity.Domain.Entities;

namespace SdxCore.Identity.Application.Contracts.Services;
public interface IRefreshTokenService
{
    string GenerateRefreshToken();

    Task<RefreshTokenResponse> CreateAsync(Guid employeeId, CancellationToken ct = default);

    Task<AuthenticationResponse> RefreshTokenAsync(RefreshTokenRequest refreshTokenRequest, CancellationToken ct = default);

    Task RevokeRefreshTokenAsync(string refreshToken, CancellationToken ct = default);
}