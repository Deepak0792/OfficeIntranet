using SdxCore.Identity.Application.Enums;

namespace SdxCore.Identity.Domain.DTOs.Request;

public sealed class AuditEventRequest
{
    public string EventType { get; set; } = default!;
    public AuthProtocol Protocol { get; set; }

    public Guid EmployeeId { get; set; }
    public string? Username { get; set; }

    public string? IpAddress { get; set; }

    public string? FailureReason { get; set; }
}