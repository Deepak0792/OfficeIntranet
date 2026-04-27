using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Interfaces;
using SdxCore.Identity.Persistence.Data;

namespace SdxCore.Identity.Persistence.Repositories;

/// <summary>
/// Repository implementation for audit event data access.
/// Uses Entity Framework Core to manage AuditEvent entities in SQL Server.
/// This is an append-only repository - audit events should never be modified or deleted.
/// </summary>
public class AuditRepository : IAuditRepository
{
    private readonly IdentityDbContext _context;

    /// <summary>
    /// Initializes a new instance of the <see cref="AuditRepository"/> class.
    /// </summary>
    /// <param name="context">The database context.</param>
    public AuditRepository(IdentityDbContext context)
    {
        _context = context ?? throw new ArgumentNullException(nameof(context));
    }

    /// <inheritdoc />
    public async Task InsertAsync(AuditEvent auditEvent, CancellationToken ct = default)
    {
        if (auditEvent is null)
            throw new ArgumentNullException(nameof(auditEvent));

        _context.AuditEvents.Add(auditEvent);
        await _context.SaveChangesAsync(ct);
    }
}
