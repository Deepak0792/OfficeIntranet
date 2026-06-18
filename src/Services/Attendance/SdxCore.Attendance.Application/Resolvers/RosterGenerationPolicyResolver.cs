using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Application.DTOs.RosterPolicy.Response;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Common.Enums.Workflow;

namespace SdxCore.Attendance.Application.Resolvers;

public class RosterGenerationPolicyResolver(
    IEmployeeScopeResolver employeeScopeResolver,
    IScopeResolver scopeResolver,
    IRosterGenerationPolicyRepository policyRepository,
    IRosterGenerationPolicyAssignmentRepository assignmentRepository)
    : IRosterGenerationPolicyResolver
{
    public async Task<ResolvedRosterGenerationPolicy?> ResolveAsync(
        Guid employeeId,
        DateOnly rosterDate,
        CancellationToken cancellationToken = default)
    {
        var scope =
            await employeeScopeResolver.ResolveAsync(
                employeeId,
                cancellationToken);

        if (scope is null)
            return null;

        var assignments =
            await assignmentRepository.GetActiveAssignmentsAsync(
                cancellationToken);

        RosterGenerationPolicyAssignment? matched = null;

        foreach (var assignment in assignments.OrderBy(x => x.PriorityOrder))
        {
            if (!IsWithinDate(assignment, rosterDate))
                continue;

            var scopeCode =
                await scopeResolver.GetScopeCodeByIdAsync(
                    assignment.ScopeTypeId,
                    cancellationToken);

            bool isMatch = scopeCode switch
            {
                ScopeTypeCodes.Employee =>
                    assignment.ScopeReferenceId == employeeId,

                ScopeTypeCodes.Team =>
                    assignment.ScopeReferenceId == scope.TeamId,

                ScopeTypeCodes.Department =>
                    assignment.ScopeReferenceId == scope.DepartmentId,

                ScopeTypeCodes.Office =>
                    assignment.ScopeReferenceId == scope.OfficeLocationId,

                ScopeTypeCodes.LegalEntity =>
                    assignment.ScopeReferenceId == scope.LegalEntityId,

                ScopeTypeCodes.Country =>
                    assignment.ScopeReferenceId == scope.CountryId,

                ScopeTypeCodes.Global =>
                    assignment.ScopeReferenceId == null,

                _ => false
            };

            if (!isMatch)
                continue;

            matched = assignment;
            break;
        }

        if (matched is null)
            return null;

        var policy =
            await policyRepository.GetByIdAsync(
                matched.RosterGenerationPolicyId,
                cancellationToken);

        if (policy is null)
            return null;

        return new ResolvedRosterGenerationPolicy
        {
            PolicyId = policy.Id,
            PolicyCode = policy.PolicyCode,
            PolicyName = policy.PolicyName,
            GenerationType = policy.GenerationType,
            GenerateDaysBefore = policy.GenerateDaysBefore,
            AutoGenerate = policy.AutoGenerate,
            LockAfterGeneration = policy.LockAfterGeneration
        };
    }

    public async Task<bool> IsMonthlyAsync(
        Guid employeeId,
        DateOnly rosterDate,
        CancellationToken cancellationToken = default)
    {
        var policy =
            await ResolveAsync(
                employeeId,
                rosterDate,
                cancellationToken);

        return policy?.GenerationType == "MONTHLY";
    }

    public async Task<bool> IsWeeklyAsync(
        Guid employeeId,
        DateOnly rosterDate,
        CancellationToken cancellationToken = default)
    {
        var policy =
            await ResolveAsync(
                employeeId,
                rosterDate,
                cancellationToken);

        return policy?.GenerationType == "WEEKLY";
    }

    private static bool IsWithinDate(
        RosterGenerationPolicyAssignment assignment,
        DateOnly date)
    {
        if (date < assignment.EffectiveFrom)
            return false;

        if (assignment.EffectiveTo.HasValue &&
            date > assignment.EffectiveTo.Value)
            return false;

        return true;
    }
}