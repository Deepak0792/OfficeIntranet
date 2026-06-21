using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface ILeaveResolver
{
    Task<bool> IsOnLeaveAsync(
        Guid employeeId,
        DateOnly attendanceDate,
        CancellationToken cancellationToken = default);

    Task<LeaveRequest?> ResolveAsync(
        Guid employeeId,
        DateOnly attendanceDate,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyCollection<LeaveRequest>> GetLeavesAsync(
        Guid employeeId,
        DateOnly fromDate,
        DateOnly toDate,
        CancellationToken cancellationToken = default);

    Task<decimal> GetLeaveDaysAsync(
        Guid employeeId,
        DateOnly fromDate,
        DateOnly toDate,
        CancellationToken cancellationToken = default);

    Task<bool> IsHalfDayLeaveAsync(
        Guid employeeId,
        DateOnly attendanceDate,
        CancellationToken cancellationToken = default);
}