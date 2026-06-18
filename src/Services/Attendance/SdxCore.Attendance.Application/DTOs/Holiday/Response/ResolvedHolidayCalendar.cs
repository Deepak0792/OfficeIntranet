namespace SdxCore.Attendance.Application.DTOs.Holiday.Response;

public record ResolvedHolidayCalendar(
    Guid HolidayCalendarId,
    string CalendarName,
    string MergeStrategy,
    bool IsPrimary,
    DateOnly? EffectiveFrom,
    DateOnly? EffectiveTo,
    int PriorityOrder,
    string ScopeCode);