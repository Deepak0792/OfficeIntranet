namespace SdxCore.Attendance.Application.DTOs.Holiday.Response;

public class EmployeeHolidayResponse
{
    public Guid HolidayId { get; set; }

    public string HolidayCode { get; set; } = null!;

    public string HolidayName { get; set; } = null!;

    public DateOnly HolidayDate { get; set; }

    public string HolidayTypeCode { get; set; } = null!;

    public bool IsHalfDay { get; set; }

    public string? HalfDaySession { get; set; }

    public string CalendarName { get; set; } = null!;

    public string ScopeCode { get; set; } = null!;
}