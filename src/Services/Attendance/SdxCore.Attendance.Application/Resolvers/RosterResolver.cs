using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Resolvers;

public class RosterResolver(
    IEmployeeShiftRosterRepository rosterRepository)
    : IRosterResolver
{
    public async Task<EmployeeShiftRoster> ResolveAsync(Guid rosterId, CancellationToken cancellationToken = default)
    {
        return await rosterRepository.GetByIdAsync(rosterId, cancellationToken)
            ?? throw new InvalidOperationException($"Roster not found for ID '{rosterId}'.");
    }

    public async Task<EmployeeShiftRoster> ResolveEmployeeRosterAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default)
    {
        return await rosterRepository.GetByEmployeeDateAsync(employeeId, date, cancellationToken)
            ?? throw new InvalidOperationException($"Roster not found for employee '{employeeId}' on '{date}'.");
    }
}