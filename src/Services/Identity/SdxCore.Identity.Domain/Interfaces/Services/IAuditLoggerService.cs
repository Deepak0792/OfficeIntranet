using SdxCore.Identity.Domain.DTOs.Request;

namespace SdxCore.Identity.Domain.Interfaces.Services;
public interface IAuditLoggerService
{
    Task LogAsync(AuditEventRequest auditEventRequest, CancellationToken ct = default);
}
