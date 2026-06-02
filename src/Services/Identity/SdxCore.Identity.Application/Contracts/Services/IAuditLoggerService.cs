using SdxCore.Identity.Domain.DTOs.Request;

namespace SdxCore.Identity.Application.Contracts.Services;
public interface IAuditLoggerService
{
    Task LogAsync(AuditEventRequest auditEventRequest, CancellationToken ct = default);
}
