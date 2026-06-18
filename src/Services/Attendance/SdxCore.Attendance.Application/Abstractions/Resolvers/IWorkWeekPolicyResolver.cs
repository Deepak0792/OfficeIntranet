using SdxCore.Attendance.Application.DTOs.WorkWeek;
using SdxCore.Attendance.Application.DTOs.WorkWeek.Response;

namespace SdxCore.Attendance.Application.Abstractions.Resolvers;

public interface IWorkWeekPolicyResolver
{
    Task<WorkWeekPolicyResponse?> ResolvePolicyAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default);

    Task<bool> IsWorkingDayAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default);

    Task<bool> IsWeekendAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default);

    Task<bool> IsHalfDayAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default);

    Task<int> GetStandardWorkingMinutesAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyCollection<DateOnly>> GetWorkingDaysAsync(
        Guid employeeId,
        DateOnly from,
        DateOnly to,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyCollection<DateOnly>> GetWeekendsAsync(
        Guid employeeId,
        DateOnly from,
        DateOnly to,
        CancellationToken cancellationToken = default);
}