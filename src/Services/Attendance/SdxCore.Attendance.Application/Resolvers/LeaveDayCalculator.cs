using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.DTOs;

namespace SdxCore.Attendance.Application.Resolvers;

public class LeaveDayCalculator(
    IEmployeeCalendarResolver employeeCalendarResolver)
    : ILeaveDayCalculator
{
    public async Task<EmployeeCalendarResult> CalculateAsync(
        Guid employeeId,
        DateOnly fromDate,
        DateOnly toDate,
        CancellationToken cancellationToken = default)
    {
        if (fromDate > toDate)
            throw new InvalidOperationException(
                "FromDate cannot be greater than ToDate.");

        var calendar =
            await employeeCalendarResolver.ResolveAsync(
                employeeId,
                fromDate,
                toDate,
                cancellationToken);

        return calendar;
    }
}