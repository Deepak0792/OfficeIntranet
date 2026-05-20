using SdxCore.Common.Interfaces.Data;
using SdxCore.Identity.Domain.Entities;

namespace SdxCore.Identity.Domain.Interfaces.Repositories;
public interface IRefreshTokenRepository : IRepository<RefreshToken, int>
{
    Task<RefreshToken?> GetByHashAsync(string hashToken, CancellationToken ct = default);
}

