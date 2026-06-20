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
        int year,
        decimal requestedDays,
        CancellationToken cancellationToken = default)
    {
        var balance =
            await repository.GetByEmployeeAndTypeAsync(employeeId, leaveTypeId, year, cancellationToken)
                ?? throw new InvalidOperationException("Leave balance not found.");

        if (balance.ClosingBalance < requestedDays)
            throw new InvalidOperationException($"Insufficient leave balance. Available={balance.ClosingBalance}, Requested={requestedDays}");
    }

    public async Task<decimal> GetAvailableBalanceAsync(
        Guid employeeId,
        Guid leaveTypeId,
        int year,
        CancellationToken cancellationToken = default)
    {
        var balance = await repository.GetByEmployeeAndTypeAsync(employeeId, leaveTypeId, year, cancellationToken);
        return balance?.ClosingBalance ?? 0;
    }
}