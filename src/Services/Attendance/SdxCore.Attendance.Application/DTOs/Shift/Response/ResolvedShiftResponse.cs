namespace SdxCore.Attendance.Application.DTOs.Shift.Response;

public class ResolvedShiftResponse
{
    public Guid? ShiftId { get; set; }

    public string? ShiftCode { get; set; }

    public string? ShiftName { get; set; }

    public Guid TimeZoneId { get; set; }

    public TimeOnly StartTime { get; set; }

    public TimeOnly EndTime { get; set; }

    public bool CrossesMidnight { get; set; }
    public bool IsOffDay { get; set; }

    public bool IsRotationShift { get; set; }

    public Guid? RotationShiftId { get; set; }

    public DateOnly RosterDate { get; set; }
}