using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

public class AttendanceStatus : BaseAuditEntity<Guid>
{
    public required string StatusCode { get; set; }
    public required string StatusName { get; set; }
    public bool IsPresent { get; set; }
    public bool IsAbsent { get; set; }
    public bool IsPaid { get; set; }
    public bool CountsAsWorkingDay { get; set; }
    public short DisplayOrder { get; set; }
    public bool IsSystemStatus { get; set; } = true;
    public bool IsActive { get; set; } = true;
}
