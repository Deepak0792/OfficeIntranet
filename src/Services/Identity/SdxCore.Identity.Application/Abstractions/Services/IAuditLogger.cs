using SdxCore.Identity.Domain.Entities;

namespace SdxCore.Identity.Application.Abstractions.Services;

/// <summary>
/// Audit logger interface for recording authentication events.
/// All authentication attempts (success or failure) are logged for compliance and security monitoring.
/// </summary>
public interface IAuditLogger
{
    /// <summary>
    /// Logs an authentication audit event to persistent storage.
    /// </summary>
    /// <param name="auditEvent">Audit event to log.</param>
    /// <param name="ct">Cancellation token.</param>
    Task LogAsync(AuditEvent auditEvent, CancellationToken ct = default);
}
