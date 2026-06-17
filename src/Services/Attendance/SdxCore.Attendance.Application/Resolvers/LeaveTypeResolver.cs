using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Application.Exceptions;
using SdxCore.Attendance.Application.Abstractions.Resolvers;

namespace SdxCore.Attendance.Application.Resolvers;


public class LeaveTypeResolver(
    ILeaveTypeRepository repository)
    : ILeaveTypeResolver
{
    public async Task<LeaveType>
        ResolveActiveLeaveTypeAsync(
            Guid leaveTypeId,
            CancellationToken cancellationToken = default)
    {
        var entity =
            await repository.GetByIdAsync(
                leaveTypeId,
                cancellationToken);

        if (entity is null)
            throw ResolverException.NotFound(
                nameof(LeaveType),
                leaveTypeId);

        if (!entity.IsActive)
            throw ResolverException.Inactive(
                nameof(LeaveType),
                leaveTypeId);

        return entity;
    }
}