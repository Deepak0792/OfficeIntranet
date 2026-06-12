using SdxCore.Identity.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Identity.Domain.Abstractions.Repositories;
public interface IRefreshTokenRepository : IRepository<RefreshToken, Guid>
{
    Task<RefreshToken?> GetByHashAsync(string hashToken, CancellationToken ct = default);
}

