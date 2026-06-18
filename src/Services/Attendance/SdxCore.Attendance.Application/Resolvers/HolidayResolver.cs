using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.DTOs.Holiday.Response;
using SdxCore.Attendance.Domain.Abstractions.Repositories;

namespace SdxCore.Attendance.Application.Resolvers;

public class HolidayResolver(
    IHolidayRepository holidayRepository,
    IHolidayCalendarResolver holidayCalendarResolver)
    : IHolidayResolver
{
    public async Task<bool> IsHolidayAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default)
    {
        var holidays =
            await GetHolidaysAsync(
                employeeId,
                date,
                date,
                cancellationToken);

        return holidays.Count != 0;
    }

    public async Task<IReadOnlyCollection<DateOnly>>
        GetHolidayDatesAsync(
            Guid employeeId,
            DateOnly from,
            DateOnly to,
            CancellationToken cancellationToken = default)
    {
        var holidays =
            await GetHolidaysAsync(
                employeeId,
                from,
                to,
                cancellationToken);

        return holidays
            .Select(x => x.HolidayDate)
            .Distinct()
            .ToList();
    }

    public async Task<int> GetHolidayCountAsync(
        Guid employeeId,
        DateOnly from,
        DateOnly to,
        CancellationToken cancellationToken = default)
    {
        var dates =
            await GetHolidayDatesAsync(
                employeeId,
                from,
                to,
                cancellationToken);

        return dates.Count;
    }

    public async Task<IReadOnlyCollection<EmployeeHolidayResponse>>
        GetHolidaysAsync(
            Guid employeeId,
            DateOnly from,
            DateOnly to,
            CancellationToken cancellationToken = default)
    {
        var calendars =
            await holidayCalendarResolver.ResolveCalendarsAsync(
                employeeId,
                cancellationToken);

        if (!calendars.Any())
            return [];

        var calendarMap =
            calendars.ToDictionary(
                x => x.HolidayCalendarId);

        var holidays =
            await holidayRepository.GetByCalendarsAsync(
                calendarMap.Keys,
                cancellationToken);

        return holidays
            .Where(x =>
                x.HolidayDate >= from &&
                x.HolidayDate <= to)
            .Select(x =>
            {
                var calendar =
                    calendarMap[x.HolidayCalendarId];

                return new EmployeeHolidayResponse
                {
                    HolidayId = x.Id,
                    HolidayCode = x.HolidayCode,
                    HolidayName = x.HolidayName,
                    HolidayDate = x.HolidayDate,
                    HolidayTypeCode = x.HolidayType.HolidayTypeCode,
                    IsHalfDay = x.IsHalfDay,
                    HalfDaySession = x.HalfDaySession,
                    CalendarName = calendar.CalendarName,
                    ScopeCode = calendar.ScopeCode
                };
            })
            .GroupBy(x => x.HolidayDate)
            .Select(x => x.First())
            .OrderBy(x => x.HolidayDate)
            .ToList();
    }
}