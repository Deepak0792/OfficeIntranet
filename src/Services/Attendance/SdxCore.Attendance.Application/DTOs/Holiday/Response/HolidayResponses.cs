namespace SdxCore.Attendance.Application.DTOs.Holiday.Response;

public record HolidayCalendarResponse(Guid Id, string CalendarCode, string CalendarName, bool IsDefault, bool IsActive);

public record HolidayResponse(
    Guid Id,
    Guid HolidayCalendarId,
    string HolidayCode,
    string HolidayName,
    DateOnly HolidayDate,
    bool IsHalfDay,
    bool IsRecurring,
    short? ApplicableYear,
    string? Description,
    bool IsActive);
