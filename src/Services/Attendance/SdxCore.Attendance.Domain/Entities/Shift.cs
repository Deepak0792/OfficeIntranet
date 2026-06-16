using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

public class Shift : BaseAuditEntity<Guid>, IPublishableEntity
{
    public required string ShiftCode { get; set; }
    public required string ShiftName { get; set; }
    public TimeOnly StartTime { get; set; }
    public TimeOnly EndTime { get; set; }
    public short BreakDurationMinutes { get; set; }
    public short GraceInMinutes { get; set; }
    public short GraceOutMinutes { get; set; }
    public short? MinimumWorkingMinutes { get; set; }
    public short? MaximumWorkingMinutes { get; set; }
    public short AttendanceFinalizeBufferMinutes { get; set; }
    public short? MaxAllowedCheckoutDelayMinutes { get; set; }
    public bool IsNightShift { get; set; }
    public bool CrossesMidnight { get; set; }
    public bool IsFlexible { get; set; }
    public bool AllowOvertime { get; set; }
    public bool IsActive { get; set; } = true;
}
