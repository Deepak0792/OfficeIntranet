using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.Exceptions;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Resolvers;


public class ShiftResolver(
    IShiftRepository repository)
    : IShiftResolver
{
    public async Task<Shift>
        ResolveActiveShiftAsync(
            Guid shiftId,
            CancellationToken cancellationToken = default)
    {
        var entity =
            await repository.GetByIdAsync(
                shiftId,
                cancellationToken);

        if (entity is null)
            throw ResolverException.NotFound(
                nameof(Shift),
                shiftId);

        if (!entity.IsActive)
            throw ResolverException.Inactive(
                nameof(Shift),
                shiftId);

        return entity;
    }
}