using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

public class AttendanceLog : BaseAuditEntity<Guid>
{
    /// <summary>Cross-schema FK to employee.Employee — ID only, no nav prop.</summary>
    public Guid EmployeeId { get; set; }

    public DateTime PunchTime { get; set; }
    public required string PunchType { get; set; }
    public string? DeviceId { get; set; }
    public string? Location { get; set; }
    public bool IsProcessed { get; set; }
    public bool IsActive { get; set; } = true;
    public short RetryCount { get; set; }
    public string? ErrorMessage { get; set; }
}
