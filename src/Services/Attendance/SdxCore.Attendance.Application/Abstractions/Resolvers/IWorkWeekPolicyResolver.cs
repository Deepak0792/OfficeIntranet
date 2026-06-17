using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IWorkWeekPolicyResolver
{
    Task<bool> IsWeeklyOffAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default);

    Task<WorkWeekPolicy> ResolvePolicyAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default);
}