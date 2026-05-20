using SdxCore.Common.Interfaces.Contexts;
using Microsoft.EntityFrameworkCore;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Interfaces.Repositories;
using SdxCore.Identity.Persistence.Data;

namespace SdxCore.Identity.Persistence.Repositories;

/// <summary>
/// Repository implementation for audit event data access.
/// Uses Entity Framework Core to manage AuditEvent entities in SQL Server.
/// This is an append-only repository - audit events should never be modified or deleted.
/// </summary>
/// <remarks>
/// Initializes a new instance of the <see cref="AuditRepository"/> class.
/// </remarks>
/// <param name="dbContext">The database context.</param>
public class AuditRepository : BaseRepository<AuditEvent>, IAuditRepository
{
    public AuditRepository(IdentityDbContext dbContext, IRequestContext requestContext) : base(dbContext, requestContext)
    {
    }

    /// <inheritdoc />
    public async Task<IReadOnlyList<AuditEvent>> GetByUsernameAsync(string username, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(username))
            return [];

        return await _dbContext.AuditEvents
            .Where(e => e.Username == username)
            .OrderByDescending(e => e.CreatedAt)
            .ToListAsync(ct);
    }
}


