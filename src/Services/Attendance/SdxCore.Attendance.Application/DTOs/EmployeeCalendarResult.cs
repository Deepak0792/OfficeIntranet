namespace SdxCore.Attendance.Application.DTOs;

public sealed class EmployeeCalendarResult
{
    public IReadOnlyCollection<DateOnly> WorkingDays { get; init; } = [];

    public IReadOnlyCollection<DateOnly> WeekendDays { get; init; } = [];

    public IReadOnlyCollection<DateOnly> HolidayDays { get; init; } = [];

    public IReadOnlyCollection<DateOnly> WorkingHolidayDays { get; init; } = [];

    public decimal PayableDays =>
        WorkingDays.Count;

    public int TotalDays =>
        WorkingDays.Count +
        WeekendDays.Count +
        HolidayDays.Count;

    public bool IsWorkingDay(DateOnly date)
        => WorkingDays.Contains(date);

    public bool IsHoliday(DateOnly date)
        => HolidayDays.Contains(date);

    public bool IsWeekend(DateOnly date)
        => WeekendDays.Contains(date);
}