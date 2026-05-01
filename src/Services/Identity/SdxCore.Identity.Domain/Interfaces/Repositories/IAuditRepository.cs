using SdxCore.Identity.Domain.Entities;

namespace SdxCore.Identity.Domain.Interfaces.Repositories;

/// <summary>
/// Repository interface for audit event data access.
/// Provides append-only access to audit logs for compliance and security monitoring.
/// </summary>
public interface IAuditRepository
{
    /// <summary>
    /// Inserts a new audit event record.
    /// This is an append-only operation - audit events should never be modified or deleted.
    /// </summary>
    /// <param name="auditEvent">Audit event to insert.</param>
    /// <param name="ct">Cancellation token.</param>
    Task InsertAsync(AuditEvent auditEvent, CancellationToken ct = default);

    /// <summary>
    /// Retrieves audit events for a specific username.
    /// Used for testing and compliance reporting.
    /// </summary>
    /// <param name="username">Username to search for.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>List of audit events for the specified username.</returns>
    Task<IReadOnlyList<AuditEvent>> GetByUsernameAsync(string username, CancellationToken ct = default);
}
