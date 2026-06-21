namespace SdxCore.Attendance.Application.DTOs.Shift.Response;

public class ResolvedShiftResponse
{
    public Guid? ShiftId { get; set; }

    public string? ShiftCode { get; set; }

    public string? ShiftName { get; set; }

    public Guid TimeZoneId { get; set; }

    public TimeOnly StartTime { get; set; }

    public TimeOnly EndTime { get; set; }
    public short GraceInMinutes { get; set; }
    public short GraceOutMinutes { get; set; }
    public short? MinimumWorkingMinutes { get; set; }
    public short? MaximumWorkingMinutes { get; set; }
    public short? AttendanceFinalizeBufferMinutes { get; set; }
    public short? MaxAllowedCheckoutDelayMinutes { get; set; }
    public bool CrossesMidnight { get; set; }
    public bool IsOffDay { get; set; }
    public bool IsNightShift { get; set; }
    public bool IsRotationShift { get; set; }
    public bool AllowOvertime { get; set; }
    public bool IsFlexible { get; set; }
    public Guid? RotationShiftId { get; set; }

    public DateOnly RosterDate { get; set; }
}