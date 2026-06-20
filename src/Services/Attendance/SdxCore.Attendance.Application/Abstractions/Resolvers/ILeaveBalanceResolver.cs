namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface ILeaveBalanceResolver
{
    Task ValidateLeaveBalanceAsync(
        Guid employeeId,
        Guid leaveTypeId,
        int year,
        decimal requestedDays,
        CancellationToken cancellationToken = default);
}