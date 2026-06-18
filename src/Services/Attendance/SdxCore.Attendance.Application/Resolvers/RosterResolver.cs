using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Resolvers;

public class RosterResolver(
    IEmployeeShiftRosterRepository rosterRepository)
    : IRosterResolver
{
    public async Task<EmployeeShiftRoster> ResolveAsync(
        Guid rosterId,
        CancellationToken cancellationToken = default)
    {
        var roster =
            await rosterRepository.GetByIdAsync(
                rosterId,
                cancellationToken);

        if (roster is null)
            throw new InvalidOperationException(
                $"Roster '{rosterId}' not found.");

        return roster;
    }

    public async Task<EmployeeShiftRoster> ResolveEmployeeRosterAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default)
    {
        var roster =
            await rosterRepository.GetByEmployeeAndDateAsync(
                employeeId,
                date,
                cancellationToken);

        if (roster is null)
            throw new InvalidOperationException(
                $"Roster not found for employee '{employeeId}' on '{date:yyyy-MM-dd}'.");

        return roster;
    }
}