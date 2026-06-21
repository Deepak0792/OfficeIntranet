using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;
public class AttendanceCalculationQueue : BaseAuditEntity<Guid>
{
    public Guid EmployeeId { get; set; }

    public DateOnly AttendanceDate { get; set; }

    public short? ReasonCode { get; set; }

    public byte Priority { get; set; } = 1;

    public short RetryCount { get; set; }

    public DateTime? LastAttemptAt { get; set; }

    public DateTime? ProcessedAt { get; set; }

    public string? ErrorMessage { get; set; }

    public bool IsActive { get; set; } = true;
}