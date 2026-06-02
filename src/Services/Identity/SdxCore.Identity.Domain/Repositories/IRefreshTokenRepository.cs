using SdxCore.Identity.Domain.Entities;
using SdxCore.SharedKernel.Persistence.Repositories.Contracts;

namespace SdxCore.Identity.Domain.Repositories;
public interface IRefreshTokenRepository : IRepository<RefreshToken, int>
{
    Task<RefreshToken?> GetByHashAsync(string hashToken, CancellationToken ct = default);
}

