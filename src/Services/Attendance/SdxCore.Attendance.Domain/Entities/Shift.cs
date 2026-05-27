using System;
using System.Collections.Generic;

namespace SdxCore.Attendance.Domain.Entities;

public class Shift : BaseEntity
{
    public short Id { get; set; }
    public string ShiftCode { get; set; } = string.Empty;
    public string ShiftName { get; set; } = string.Empty;
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }
    public short BreakDurationMinutes { get; set; } = 0;
    public short GraceInMinutes { get; set; } = 0;
    public short GraceOutMinutes { get; set; } = 0;
    public short? MinimumWorkingMinutes { get; set; }
    public short? MaximumWorkingMinutes { get; set; }
    public short AttendanceFinalizeBufferMinutes { get; set; } = 240;
    public short? MaxAllowedCheckoutDelayMinutes { get; set; }
    public bool IsNightShift { get; set; } = false;
    public bool CrossesMidnight { get; set; } = false;
    public bool IsFlexible { get; set; } = false;
    public bool AllowOvertime { get; set; } = true;
}
