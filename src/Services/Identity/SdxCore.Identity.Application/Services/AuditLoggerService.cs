using Microsoft.Extensions.Logging;
using SdxCore.Common.Interfaces.Contexts;
using SdxCore.Identity.Domain.DTOs.Request;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Interfaces.Services;

namespace SdxCore.Identity.Application.Services;
public sealed class AuditLoggerService : IAuditLoggerService
{
    private readonly IAuditLogger _auditLogger;
    private readonly ILogger<AuditLoggerService> _logger;
    private readonly IRequestContext _requestContext;

    public AuditLoggerService(
        IAuditLogger auditLogger,
        IRequestContext requestContext,
        ILogger<AuditLoggerService> logger)
    {
        _auditLogger = auditLogger;
        _logger = logger;
        _requestContext = requestContext;
    }

    public async Task LogAsync(AuditEventRequest auditEventRequest, CancellationToken ct = default)
    {
        try
        {
            AuditEvent auditEvent = new AuditEvent
            {
                EventType = auditEventRequest.EventType,
                Protocol = auditEventRequest.Protocol,
                EmployeeId = auditEventRequest.EmployeeId,
                Username = auditEventRequest.Username,
                IpAddress = _requestContext.IpAddress,
                FailureReason = auditEventRequest.FailureReason
            };

            await _auditLogger.LogAsync(auditEvent, ct);
        }
        catch (Exception ex)
        {
            // Never break authentication flow due to audit failure
            _logger.LogError(ex,
                "Failed to write audit event: {EventType}",
                auditEventRequest.EventType);
        }
    }
}