using Microsoft.Extensions.Logging;
using SdxCore.Common.Contexts;
using SdxCore.Identity.Domain.DTOs.Request;
using SdxCore.Identity.Domain.Entities;
using SdxCore.Identity.Domain.Interfaces.Services;

namespace SdxCore.Identity.Application.Services;
public sealed class AuditLoggerService : IAuditLoggerService
{
    private readonly IAuditLogger _auditLogger;
    private readonly ILogger<AuditLoggerService> _logger;

    public AuditLoggerService(
        IAuditLogger auditLogger,
        IRequestContext requestContext,
        ILogger<AuditLoggerService> logger)
    {
        _auditLogger = auditLogger;
        _logger = logger;
    }

    public async Task LogAsync(AuditEventRequest auditEventRequest, CancellationToken ct = default)
    {
        try
        {
            AuditEvent auditEvent = new AuditEvent
            {
                EventType = auditEventRequest.EventType,
                Protocol = auditEventRequest.Protocol,
                UserId = auditEventRequest.UserId,
                Username = auditEventRequest.Username,
                IpAddress = auditEventRequest.IpAddress ?? throw new ArgumentNullException(nameof(auditEventRequest.IpAddress)),
                FailureReason = auditEventRequest.FailureReason,
                OccurredAt = DateTimeOffset.UtcNow
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