using System;

namespace SdxCore.Attendance.Domain.Entities;

public class AttendanceRecord : BaseEntity
{
    public long Id { get; set; }
    public int EmployeeId { get; set; }
    public long? EmployeeShiftId { get; set; }
    public long? WorkSessionId { get; set; }
    public DateTime AttendanceDate { get; set; }
    public short? ShiftId { get; set; }
    public string? AttendanceStatus { get; set; }
    public DateTime? CheckInTime { get; set; }
    public DateTime? CheckOutTime { get; set; }
    public short? LateByMinutes { get; set; }
    public short? EarlyExitMinutes { get; set; }
    public short? WorkedMinutes { get; set; }
    public short BreakMinutes { get; set; } = 0;
    public short OvertimeMinutes { get; set; } = 0;
    public bool IsNightShift { get; set; } = false;
    public bool IsCrossDayAttendance { get; set; } = false;
    public bool IsWeeklyOff { get; set; } = false;
    public bool IsHoliday { get; set; } = false;
    public bool IsOnLeave { get; set; } = false;
    public bool IsManualEntry { get; set; } = false;
    public bool IsAutoProcessed { get; set; } = true;
    public bool IsAttendanceLocked { get; set; } = false;
    public string? Remarks { get; set; }
    public int? ApprovedBy { get; set; }
    public DateTime? ApprovedAt { get; set; }
}
