using SdxCore.Identity.Application.DTOs.Audit.Request;

namespace SdxCore.Identity.Application.Abstractions.Services;
public interface IAuditLoggerService
{
    Task LogAsync(AuditEventRequest auditEventRequest, CancellationToken ct = default);
}
