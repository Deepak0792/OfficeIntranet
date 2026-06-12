using SdxCore.Identity.Application.DTOs.Auth.Response;
using SdxCore.Identity.Application.DTOs.Token.Request;
using SdxCore.Identity.Application.DTOs.Token.Response;
using SdxCore.Identity.Domain.Entities;

namespace SdxCore.Identity.Application.Abstractions.Services;
public interface IRefreshTokenService
{
    string GenerateRefreshToken();

    Task<RefreshTokenResponse> CreateAsync(Guid employeeId, CancellationToken ct = default);

    Task<AuthenticationResponse> RefreshTokenAsync(RefreshTokenRequest refreshTokenRequest, CancellationToken ct = default);

    Task RevokeRefreshTokenAsync(string refreshToken, CancellationToken ct = default);
}