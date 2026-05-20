using SdxCore.Common.Interfaces.Contexts;
using Microsoft.EntityFrameworkCore;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Interfaces.Repositories;
using SdxCore.Identity.Persistence.Data;

namespace SdxCore.Identity.Persistence.Repositories;
public sealed class RefreshTokenRepository : BaseRepository<RefreshToken>, IRefreshTokenRepository
{
    public RefreshTokenRepository(IdentityDbContext dbContext, IRequestContext requestContext) : base(dbContext, requestContext)
    {
    }

    /// <summary>
    /// Gets refresh token by hashed value.
    /// </summary>
    public async Task<RefreshToken?> GetByHashAsync(string hashToken, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(hashToken))
            return null;

        return await _dbContext.RefreshTokens
            .AsNoTracking()
            .FirstOrDefaultAsync(t => t.HashToken == hashToken, ct);
    }
}

