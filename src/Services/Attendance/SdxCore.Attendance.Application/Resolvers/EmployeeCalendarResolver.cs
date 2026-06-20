using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.DTOs;

namespace SdxCore.Attendance.Application.Resolvers;

public class EmployeeCalendarResolver(
    IHolidayResolver holidayResolver,
    IWorkWeekPolicyResolver workWeekPolicyResolver)
    : IEmployeeCalendarResolver
{
    public async Task<EmployeeCalendarResult> ResolveAsync(
        Guid employeeId,
        DateOnly fromDate,
        DateOnly toDate,
        CancellationToken cancellationToken = default)
    {
        var workingDays = new List<DateOnly>();
        var weekends = new List<DateOnly>();
        var holidays = new List<DateOnly>();

        for (var date = fromDate;
             date <= toDate;
             date = date.AddDays(1))
        {
            var isHoliday =
                await holidayResolver.IsHolidayAsync(
                    employeeId,
                    date,
                    cancellationToken);

            if (isHoliday)
            {
                holidays.Add(date);
                continue;
            }

            var isWeekend =
                await workWeekPolicyResolver.IsWeekendAsync(
                    employeeId,
                    date,
                    cancellationToken);

            if (isWeekend)
            {
                weekends.Add(date);
                continue;
            }

            workingDays.Add(date);
        }

        return new EmployeeCalendarResult
        {
            WorkingDays = workingDays,
            WeekendDays = weekends,
            HolidayDays = holidays
        };
    }
}