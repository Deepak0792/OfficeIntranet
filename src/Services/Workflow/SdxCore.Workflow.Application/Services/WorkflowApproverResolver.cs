using SdxCore.Workflow.Domain.Enums;
using SdxCore.Workflow.Domain.Exceptions;
using SdxCore.Workflow.Domain.Repositories;
using Microsoft.Extensions.Logging;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Domain.Resolver;

namespace SdxCore.Workflow.Application.Services;

public class WorkflowApproverResolver(
    IWorkflowStepApproverRepository approverRepo,
    IEmployeeOrgQueryService orgService,
    ILogger<WorkflowApproverResolver> logger) : IWorkflowApproverResolver
{
    public async Task<IEnumerable<ResolvedApprover>> ResolveAsync(
        short workflowStepId, int initiatorEmployeeId)
    {
        var approverRules = await approverRepo.GetByStepIdAsync(workflowStepId);
        var activeRules = approverRules.Where(r => r.IsActive).OrderBy(r => r.PriorityOrder).ToList();

        if (!activeRules.Any())
            throw new WorkflowApproverResolutionException(workflowStepId,
                "No active approver rules found.");

        var results = new List<ResolvedApprover>();

        foreach (var rule in activeRules)
        {
            var resolved = rule.WorkflowApproverType switch
            {
                WorkflowApproverType.ReportingManager =>
                    await ResolveReportingManagerAsync(rule.Id, initiatorEmployeeId),

                WorkflowApproverType.SkipManager =>
                    await ResolveSkipManagerAsync(rule.Id, initiatorEmployeeId),

                WorkflowApproverType.Employee =>
                    await ResolveFixedEmployeeAsync(rule.Id, rule.ScopeReferenceId),

                WorkflowApproverType.Designation =>
                    await ResolveByDesignationAsync(rule.Id, workflowStepId,
                        rule.ScopeTypeId, rule.ScopeReferenceId, initiatorEmployeeId),

                WorkflowApproverType.Role =>
                    await ResolveByRoleAsync(rule.Id, rule.ScopeTypeId,
                        rule.ScopeReferenceId, initiatorEmployeeId),

                _ => throw new WorkflowApproverResolutionException(workflowStepId,
                    $"Unknown ApproverType '{rule.WorkflowApproverType}'.")
            };

            results.AddRange(resolved);
        }

        if (!results.Any())
        {
            logger.LogWarning(
                "No approvers resolved for WorkflowStep {StepId}, Initiator {EmployeeId}",
                workflowStepId, initiatorEmployeeId);
            throw new WorkflowApproverResolutionException(workflowStepId,
                $"Could not resolve any approver for initiator {initiatorEmployeeId}.");
        }

        return results;
    }

    // ── Resolution strategies ────────────────────────────────

    private async Task<IEnumerable<ResolvedApprover>> ResolveReportingManagerAsync(
        short approverId, int initiatorEmployeeId)
    {
        var manager = await orgService.GetReportingManagerAsync(initiatorEmployeeId);
        if (manager is null) return [];

        return [new ResolvedApprover(
            approverId,
            WorkflowApproverType.ReportingManager,
            manager.EmployeeId,
            manager.DisplayName,
            manager.DesignationName,
            manager.DepartmentName)];
    }

    private async Task<IEnumerable<ResolvedApprover>> ResolveSkipManagerAsync(
        short approverId, int initiatorEmployeeId)
    {
        // Get reporting manager first, then their reporting manager
        var manager = await orgService.GetReportingManagerAsync(initiatorEmployeeId);
        if (manager is null) return [];

        var skipManager = await orgService.GetReportingManagerAsync(manager.EmployeeId);
        if (skipManager is null) return [];

        return [new ResolvedApprover(
            approverId,
            WorkflowApproverType.SkipManager,
            skipManager.EmployeeId,
            skipManager.DisplayName,
            skipManager.DesignationName,
            skipManager.DepartmentName)];
    }

    private async Task<IEnumerable<ResolvedApprover>> ResolveFixedEmployeeAsync(
        short approverId, short? scopeReferenceId)
    {
        if (scopeReferenceId is null) return [];

        var emp = await orgService.GetEmployeeByIdAsync((int)scopeReferenceId);
        if (emp is null) return [];

        return [new ResolvedApprover(
            approverId,
            WorkflowApproverType.Employee,
            emp.EmployeeId,
            emp.DisplayName,
            emp.DesignationName,
            emp.DepartmentName)];
    }

    private async Task<IEnumerable<ResolvedApprover>> ResolveByDesignationAsync(
        short approverId, short stepId,
        short? scopeTypeId, short? scopeReferenceId, int initiatorEmployeeId)
    {
        // Get qualifying designation IDs for this approver rule
        var designationIds = await approverRepo.GetDesignationIdsAsync(approverId);
        if (!designationIds.Any()) return [];

        // Determine scope: null ScopeReferenceId = use initiator's own scope
        int? resolvedScopeId = scopeReferenceId is not null
            ? (int)scopeReferenceId
            : await orgService.GetScopeReferenceIdAsync(initiatorEmployeeId, scopeTypeId);

        var employees = await orgService.GetEmployeesByDesignationInScopeAsync(
            designationIds, scopeTypeId, resolvedScopeId);

        return employees.Select(e => new ResolvedApprover(
            approverId,
            WorkflowApproverType.Designation,
            e.EmployeeId,
            e.DisplayName,
            e.DesignationName,
            e.DepartmentName));
    }

    private async Task<IEnumerable<ResolvedApprover>> ResolveByRoleAsync(
        short approverId, short? scopeTypeId, short? scopeReferenceId, int initiatorEmployeeId)
    {
        // Role-based resolution delegates to auth schema lookup
        // Returns employees who hold the required role in the given scope
        int? resolvedScopeId = scopeReferenceId is not null
            ? (int)scopeReferenceId
            : await orgService.GetScopeReferenceIdAsync(initiatorEmployeeId, scopeTypeId);

        var employees = await orgService.GetEmployeesByRoleInScopeAsync(
            approverId, scopeTypeId, resolvedScopeId);

        return employees.Select(e => new ResolvedApprover(
            approverId,
            WorkflowApproverType.Role,
            e.EmployeeId,
            e.DisplayName,
            e.DesignationName,
            e.DepartmentName));
    }
}
