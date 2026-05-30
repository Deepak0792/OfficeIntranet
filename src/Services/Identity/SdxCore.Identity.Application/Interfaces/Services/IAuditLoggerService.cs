using SdxCore.Identity.Domain.DTOs.Request;

namespace SdxCore.Identity.Application.Interfaces.Services;
public interface IAuditLoggerService
{
    Task LogAsync(AuditEventRequest auditEventRequest, CancellationToken ct = default);
}
