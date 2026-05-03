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
public sealed class RefreshTokenRepository : IRefreshTokenRepository
{
    private readonly IdentityDbContext _dbContext;

    public RefreshTokenRepository(IdentityDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    /// <summary>
    /// Adds a new refresh token to the database.
    /// </summary>
    public async Task AddAsync(RefreshToken token, CancellationToken ct = default)
    {
        if (token is null)
            throw new ArgumentNullException(nameof(token));

        await _dbContext.RefreshTokens.AddAsync(token, ct);
        await _dbContext.SaveChangesAsync(ct);
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

    /// <summary>
    /// Updates refresh token (rotation, revoke, etc.)
    /// </summary>
    public async Task UpdateAsync(RefreshToken token, CancellationToken ct = default)
    {
        if (token is null)
            throw new ArgumentNullException(nameof(token));

        _dbContext.RefreshTokens.Update(token);
        await _dbContext.SaveChangesAsync(ct);
    }
}