namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface ILeaveBalanceResolver
{
    Task ValidateLeaveBalanceAsync(
        Guid employeeId,
        Guid leaveTypeId,
        DateOnly fromDate,
        DateOnly toDate,
        CancellationToken cancellationToken = default);
}