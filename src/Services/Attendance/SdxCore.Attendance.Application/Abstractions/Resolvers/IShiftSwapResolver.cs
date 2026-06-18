using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IShiftSwapResolver
{
    Task<ShiftSwapRequest> ResolveAsync(
        Guid shiftSwapRequestId,
        CancellationToken cancellationToken = default);
}