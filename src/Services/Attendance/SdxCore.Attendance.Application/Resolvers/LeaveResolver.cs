using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Common.Enums.Attendance;

namespace SdxCore.Attendance.Application.Resolvers;

public class LeaveResolver(
    ILeaveRequestRepository leaveRequestRepository)
    : ILeaveResolver
{
    public async Task<bool> IsOnLeaveAsync(
        Guid employeeId,
        DateOnly attendanceDate,
        CancellationToken cancellationToken = default)
    {
        return await ResolveAsync(
            employeeId,
            attendanceDate,
            cancellationToken) is not null;
    }

    public async Task<LeaveRequest?> ResolveAsync(
        Guid employeeId,
        DateOnly attendanceDate,
        CancellationToken cancellationToken = default)
    {
        return await leaveRequestRepository.GetApprovedLeaveForDateAsync(employeeId, attendanceDate, cancellationToken);
    }

    public async Task<IReadOnlyCollection<LeaveRequest>>
        GetLeavesAsync(
            Guid employeeId,
            DateOnly fromDate,
            DateOnly toDate,
            CancellationToken cancellationToken = default)
    {
        return await leaveRequestRepository.GetApprovedLeaveForDateAsync(
            employeeId,
            fromDate,
            toDate,
            cancellationToken);
    }

    public async Task<decimal>
        GetLeaveDaysAsync(
            Guid employeeId,
            DateOnly fromDate,
            DateOnly toDate,
            CancellationToken cancellationToken = default)
    {
        var leaves =
            await GetLeavesAsync(
                employeeId,
                fromDate,
                toDate,
                cancellationToken);

        return leaves.Sum(x => x.TotalDays);
    }

    public async Task<bool>
        IsHalfDayLeaveAsync(
            Guid employeeId,
            DateOnly attendanceDate,
            CancellationToken cancellationToken = default)
    {
        var leave =
            await ResolveAsync(
                employeeId,
                attendanceDate,
                cancellationToken);

        return leave?.IsHalfDay ?? false;
    }
}