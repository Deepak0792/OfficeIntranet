namespace SdxCore.Attendance.Application.DTOs.Holiday.Request;

public record CreateHolidayCalendarRequest(
    string CalendarCode,
    string CalendarName,
    string? Description,
    bool IsDefault);

public record CreateHolidayRequest(
    Guid HolidayCalendarId,
    Guid HolidayTypeId,
    string HolidayCode,
    string HolidayName,
    DateOnly HolidayDate,
    bool IsHalfDay = false,
    string? HalfDaySession = null,
    bool IsRecurring = false,
    short? ApplicableYear = null,
    string? Description = null);

public record UpdateHolidayRequest(
    string? HolidayName,
    DateOnly? HolidayDate,
    bool? IsHalfDay,
    string? Description);
