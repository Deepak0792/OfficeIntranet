namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

using SdxCore.Attendance.Domain.Entities;

public interface ILeaveTypeResolver
{
    Task<LeaveType> ResolveActiveLeaveTypeAsync(
        Guid leaveTypeId,
        CancellationToken cancellationToken = default);
}