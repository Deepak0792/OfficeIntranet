using SdxCore.Attendance.Application.DTOs.Shift.Response;
using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IShiftResolver
{
    Task<ResolvedShiftResponse?> ResolveAsync(Guid employeeId, DateOnly rosterDate, CancellationToken cancellationToken = default);

    Task<bool> IsOffDayAsync(Guid employeeId, DateOnly rosterDate, CancellationToken cancellationToken = default);

    Task<Shift?> ResolveShiftByIdAsync(Guid shiftId, CancellationToken cancellationToken);
}