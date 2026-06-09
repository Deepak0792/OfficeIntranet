using SdxCore.Identity.Domain.Entities;
using SdxCore.SharedKernel.Persistence.Repositories.Contracts;

namespace SdxCore.Identity.Domain.Repositories;

/// <summary>
/// Repository interface for audit event data access.
/// Provides append-only access to audit logs for compliance and security monitoring.
/// </summary>
public interface IAuditRepository : IRepository<AuditEvent, Guid>
{
    /// <summary>
    /// Retrieves audit events for a specific username.
    /// Used for testing and compliance reporting.
    /// </summary>
    /// <param name="username">Username to search for.</param>
    /// <param name="ct">Cancellation token.</param>
    /// <returns>List of audit events for the specified username.</returns>
    Task<IReadOnlyList<AuditEvent>> GetByUsernameAsync(string username, CancellationToken ct = default);
}

