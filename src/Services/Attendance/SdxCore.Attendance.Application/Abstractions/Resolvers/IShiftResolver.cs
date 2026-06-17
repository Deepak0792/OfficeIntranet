using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IShiftResolver
{
    Task<Shift> ResolveActiveShiftAsync(
        Guid shiftId,
        CancellationToken cancellationToken = default);
}
