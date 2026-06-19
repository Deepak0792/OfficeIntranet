namespace SdxCore.Attendance.Application.DTOs.Shift.Response;

public record ShiftResponse(
    Guid Id,
    string ShiftCode,
    string ShiftName,
    Guid TimeZoneId,
    TimeOnly StartTime,
    TimeOnly EndTime,
    short BreakDurationMinutes,
    short GraceInMinutes,
    short GraceOutMinutes,
    bool IsNightShift,
    bool CrossesMidnight,
    bool IsFlexible,
    bool AllowOvertime,
    bool IsActive);
