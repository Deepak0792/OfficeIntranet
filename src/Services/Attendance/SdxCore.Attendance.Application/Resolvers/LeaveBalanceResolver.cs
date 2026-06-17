using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Domain.Abstractions.Repositories;

namespace SdxCore.Attendance.Application.Resolvers;


public class LeaveBalanceResolver(
    ILeaveBalanceRepository repository)
    : ILeaveBalanceResolver
{
    public async Task ValidateLeaveBalanceAsync(
        Guid employeeId,
        Guid leaveTypeId,
        DateOnly fromDate,
        DateOnly toDate,
        CancellationToken cancellationToken = default)
    {
        var year = fromDate.Year;

        var balance =
            await repository.GetByEmployeeAndLeaveTypeAsync(
                employeeId,
                leaveTypeId,
                year,
                cancellationToken);

        if (balance is null)
            throw new InvalidOperationException(
                "Leave balance not found.");

        var requestedDays =
            (toDate.DayNumber - fromDate.DayNumber) + 1;

        if (balance.BalanceDays < requestedDays)
            throw new InvalidOperationException(
                "Insufficient leave balance.");
    }
}