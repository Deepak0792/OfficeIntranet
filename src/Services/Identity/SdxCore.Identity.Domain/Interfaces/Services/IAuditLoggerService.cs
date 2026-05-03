using SdxCore.Identity.Domain.DTOs;

namespace SdxCore.Identity.Domain.Interfaces.Services;
public interface IAuditLoggerService
{
    Task LogAsync(AuditEventRequest auditEventRequest, CancellationToken ct = default);
}
