namespace SdxCore.Attendance.Application.DTOs.Shift.Request;

public record CreateShiftRequest(
    string ShiftCode,
    string ShiftName,
    TimeOnly StartTime,
    TimeOnly EndTime,
    short BreakDurationMinutes,
    short GraceInMinutes,
    short GraceOutMinutes,
    short AttendanceFinalizeBufferMinutes,
    bool IsNightShift,
    bool CrossesMidnight,
    bool IsFlexible,
    bool AllowOvertime,
    short? MinimumWorkingMinutes = null,
    short? MaximumWorkingMinutes = null,
    short? MaxAllowedCheckoutDelayMinutes = null);

public record UpdateShiftRequest(
    string? ShiftName,
    TimeOnly? StartTime,
    TimeOnly? EndTime,
    short? BreakDurationMinutes,
    short? GraceInMinutes,
    short? GraceOutMinutes,
    bool? IsNightShift,
    bool? IsFlexible,
    bool? AllowOvertime);
