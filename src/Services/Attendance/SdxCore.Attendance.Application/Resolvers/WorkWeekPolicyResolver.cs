using SdxCore.Attendance.Application.Abstractions.Clients;
using SdxCore.Attendance.Application.Abstractions.Resolvers;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;

namespace SdxCore.Attendance.Application.Resolvers;

public class WorkWeekPolicyResolver(
    IEmployeeClient employeeClient,
    IWorkWeekPolicyAssignmentRepository assignmentRepository,
    IWorkWeekPolicyRepository policyRepository,
    IWorkWeekPolicyDayRepository policyDayRepository)
    : IWorkWeekPolicyResolver
{
    public async Task<WorkWeekPolicy> ResolvePolicyAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default)
    {
        var employee =
            await employeeClient.GetEmployeeSummaryByIdAsync(
                employeeId,
                cancellationToken)
            ?? throw new InvalidOperationException(
                $"Employee {employeeId} not found.");

        var assignment =
            await assignmentRepository.GetApplicablePolicyAsync(
                employee.PrimaryTeamId,
                employee.PrimaryDepartmentId,
                employee.PrimaryLocationId,
                employee.PrimaryLegalEntityId,
                employee.EmployeeId,
                date,
                cancellationToken);

        if (assignment is null)
            throw new InvalidOperationException(
                $"No WorkWeekPolicy assigned for employee {employeeId}");

        var policy =
            await policyRepository.GetByIdAsync(
                assignment.WorkWeekPolicyId,
                cancellationToken)
            ?? throw new InvalidOperationException(
                $"WorkWeekPolicy {assignment.WorkWeekPolicyId} not found.");

        return policy;
    }

    public async Task<bool> IsWeeklyOffAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default)
    {
        var policy =
            await ResolvePolicyAsync(
                employeeId,
                date,
                cancellationToken);

        var day =
            await policyDayRepository.GetByPolicyAndDayAsync(
                policy.Id,
                (short)date.DayOfWeek,
                cancellationToken);

        if (day is null)
            return false;

        return day.IsWeeklyOff;
    }
}