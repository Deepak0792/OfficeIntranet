using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Resolvers;

public class ShiftSwapResolver(
    IShiftSwapRequestRepository repository)
    : IShiftSwapResolver
{
    public async Task<ShiftSwapRequest> ResolveAsync(
        Guid shiftSwapRequestId,
        CancellationToken cancellationToken = default)
    {
        var entity =
            await repository.GetByIdAsync(
                shiftSwapRequestId,
                cancellationToken);

        if (entity is null)
            throw new InvalidOperationException(
                $"Shift swap request '{shiftSwapRequestId}' not found.");

        return entity;
    }
}