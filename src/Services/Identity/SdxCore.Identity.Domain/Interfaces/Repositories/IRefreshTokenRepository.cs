using SdxCore.Identity.Domain.Entities;

namespace SdxCore.Identity.Domain.Interfaces.Repositories;
public interface IRefreshTokenRepository
{
    Task AddAsync(RefreshToken token, CancellationToken ct = default);

    Task<RefreshToken?> GetByHashAsync(string hashToken, CancellationToken ct = default);

    Task UpdateAsync(RefreshToken token, CancellationToken ct = default);
}
