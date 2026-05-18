using Microsoft.EntityFrameworkCore;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Interfaces.Repositories;
using SdxCore.Identity.Persistence.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SdxCore.Identity.Persistence.Repositories;
public sealed class RefreshTokenRepository : BaseRepository<RefreshToken, Guid>, IRefreshTokenRepository
{
    public RefreshTokenRepository(IdentityDbContext dbContext) : base(dbContext)
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