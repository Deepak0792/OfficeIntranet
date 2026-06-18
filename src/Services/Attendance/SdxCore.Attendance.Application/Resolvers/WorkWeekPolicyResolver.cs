using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.DTOs.WorkWeek.Response;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Caching;
using SdxCore.Common.Enums.Workflow;
using SdxCore.Common.Helpers;

namespace SdxCore.Attendance.Application.Resolvers;

public class WorkWeekPolicyResolver(
    EmployeeScopeResolver employeeScopeResolver,
    IScopeResolver scopeResolver,
    IWorkWeekPolicyRepository policyRepository,
    IWorkWeekPolicyAssignmentRepository assignmentRepository,
    ICacheService cache,
    ICacheKeyBuilder keyBuilder)
    : IWorkWeekPolicyResolver
{
    public async Task<WorkWeekPolicyResponse?> ResolvePolicyAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default)
    {
        var scope =
            await employeeScopeResolver.ResolveAsync(
                employeeId,
                cancellationToken);

        if (scope is null)
            return null;

        var assignments = await GetActiveAssignmentsAsync(cancellationToken);

        WorkWeekPolicyAssignment? matchedAssignment = null;

        foreach (var assignment in assignments.OrderBy(x => x.PriorityOrder))
        {
            if (!IsWithinDate(assignment, date))
                continue;

            var scopeCode =
                await scopeResolver.GetScopeCodeByIdAsync(
                    assignment.ScopeTypeId,
                    cancellationToken);

            bool matches = scopeCode switch
            {
                ScopeTypeCodes.Employee
                    => assignment.ScopeReferenceId == employeeId,

                ScopeTypeCodes.Team
                    => assignment.ScopeReferenceId == scope.TeamId,

                ScopeTypeCodes.Department
                    => assignment.ScopeReferenceId == scope.DepartmentId,

                ScopeTypeCodes.Office
                    => assignment.ScopeReferenceId == scope.OfficeLocationId,

                ScopeTypeCodes.LegalEntity
                    => assignment.ScopeReferenceId == scope.LegalEntityId,

                ScopeTypeCodes.Country
                    => assignment.ScopeReferenceId == scope.CountryId,

                ScopeTypeCodes.Global
                    => assignment.ScopeReferenceId == null,

                _ => false
            };

            if (!matches)
                continue;

            matchedAssignment = assignment;
            break;
        }

        if (matchedAssignment is null)
            return null;

        var policy = await policyRepository.GetByIdAsync(matchedAssignment.WorkWeekPolicyId, cancellationToken);
        return policy is null ? null : PropertyMapper.Map<WorkWeekPolicy, WorkWeekPolicyResponse>(policy);
    }
    public async Task<bool> IsWorkingDayAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default)
    {
        var policy =
            await ResolvePolicyAsync(
                employeeId,
                date,
                cancellationToken);

        if (policy is null)
            return false;

        var day =
            policy.Days.FirstOrDefault(
                x => x.DayOfWeek == (byte)date.DayOfWeek);

        return day?.IsWorkingDay ?? false;
    }

    public async Task<bool> IsWeekendAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default)
    {
        return !await IsWorkingDayAsync(
            employeeId,
            date,
            cancellationToken);
    }

    public async Task<bool> IsHalfDayAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default)
    {
        var policy =
            await ResolvePolicyAsync(
                employeeId,
                date,
                cancellationToken);

        if (policy is null)
            return false;

        var day =
            policy.Days.FirstOrDefault(
                x => x.DayOfWeek == (byte)date.DayOfWeek);

        return day?.IsHalfDay ?? false;
    }

    public async Task<int> GetStandardWorkingMinutesAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default)
    {
        var policy =
            await ResolvePolicyAsync(
                employeeId,
                date,
                cancellationToken);

        if (policy is null)
            return 0;

        var day =
            policy.Days.FirstOrDefault(
                x => x.DayOfWeek == (byte)date.DayOfWeek);

        return day?.StandardWorkingMinutes ?? 0;
    }

    public async Task<IReadOnlyCollection<DateOnly>> GetWorkingDaysAsync(
        Guid employeeId,
        DateOnly from,
        DateOnly to,
        CancellationToken cancellationToken = default)
    {
        var result = new List<DateOnly>();

        for (var date = from; date <= to; date = date.AddDays(1))
        {
            if (await IsWorkingDayAsync(
                    employeeId,
                    date,
                    cancellationToken))
            {
                result.Add(date);
            }
        }

        return result;
    }

    public async Task<IReadOnlyCollection<DateOnly>> GetWeekendsAsync(
        Guid employeeId,
        DateOnly from,
        DateOnly to,
        CancellationToken cancellationToken = default)
    {
        var result = new List<DateOnly>();

        for (var date = from; date <= to; date = date.AddDays(1))
        {
            if (await IsWeekendAsync(
                    employeeId,
                    date,
                    cancellationToken))
            {
                result.Add(date);
            }
        }

        return result;
    }

    private async Task<IReadOnlyCollection<WorkWeekPolicyAssignment>> GetActiveAssignmentsAsync(
            CancellationToken cancellationToken = default)
    {
        var key =
            keyBuilder.BuildKey(
                nameof(WorkWeekPolicyAssignment),
                "all_active");

        return await cache.GetOrSetAsync(
            key,
            async ct =>
            {
                var assignments =
                    await assignmentRepository.GetActiveAssignmentsAsync(ct);

                return assignments.ToList();
            },
            CacheOptions.StaticMasterData,
            cancellationToken)
            ?? [];
    }

    private static bool IsWithinDate(
        WorkWeekPolicyAssignment assignment,
        DateOnly date)
    {
        if (date < assignment.EffectiveFrom)
        {
            return false;
        }

        if (assignment.EffectiveTo.HasValue &&
            date > assignment.EffectiveTo.Value)
        {
            return false;
        }

        return true;
    }
}