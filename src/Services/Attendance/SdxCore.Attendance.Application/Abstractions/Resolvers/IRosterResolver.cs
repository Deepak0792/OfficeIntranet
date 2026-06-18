using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IRosterResolver
{
    Task<EmployeeShiftRoster> ResolveAsync(
        Guid rosterId,
        CancellationToken cancellationToken = default);

    Task<EmployeeShiftRoster> ResolveEmployeeRosterAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default);
}