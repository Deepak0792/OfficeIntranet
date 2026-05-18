using SdxCore.Common.Data;
using SdxCore.Identity.Domain.Entities;

namespace SdxCore.Identity.Domain.Interfaces.Repositories;
public interface IRefreshTokenRepository : IRepository<RefreshToken, Guid>
{
    Task<RefreshToken?> GetByHashAsync(string hashToken, CancellationToken ct = default);
}
