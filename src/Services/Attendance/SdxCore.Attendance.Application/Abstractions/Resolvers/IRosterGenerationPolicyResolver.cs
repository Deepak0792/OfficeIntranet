namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

using SdxCore.Attendance.Application.DTOs.RosterPolicy.Response;

public interface IRosterGenerationPolicyResolver
{
    Task<ResolvedRosterGenerationPolicy?> ResolveAsync(
        Guid employeeId,
        DateOnly rosterDate,
        CancellationToken cancellationToken = default);

    Task<bool> IsMonthlyAsync(
        Guid employeeId,
        DateOnly rosterDate,
        CancellationToken cancellationToken = default);

    Task<bool> IsWeeklyAsync(
        Guid employeeId,
        DateOnly rosterDate,
        CancellationToken cancellationToken = default);
}