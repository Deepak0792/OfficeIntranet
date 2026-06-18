namespace SdxCore.Attendance.Application.DTOs.WorkWeek.Response;

public class WorkWeekDayResponse
{
    public byte DayOfWeek { get; set; }

    public bool IsWorkingDay { get; set; }

    public bool IsHalfDay { get; set; }

    public short StandardWorkingMinutes { get; set; }
}