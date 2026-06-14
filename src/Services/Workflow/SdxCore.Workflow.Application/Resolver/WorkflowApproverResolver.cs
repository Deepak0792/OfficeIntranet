using Microsoft.Extensions.Logging;
using SdxCore.Common.Enums.Workflow;
using SdxCore.Workflow.Application.Abstractions.Resolver;
using SdxCore.Workflow.Application.Abstractions.Services;
using SdxCore.Workflow.Application.DTOs.Resolution.Response;
using SdxCore.Workflow.Domain.Exceptions;

namespace SdxCore.Workflow.Application.Resolver;

public class WorkflowApproverResolver(
    IWorkflowStepApproverService workflowStepApproverService,
    IEmployeeQueryService employeeQueryService,
    ITimeQueryService timeQueryService,
    ILogger<WorkflowApproverResolver> logger) : IWorkflowApproverResolver
{
    public async Task<IEnumerable<ResolvedApprover>> ResolveApproverAsync(
        Guid workflowStepId, Guid initiatorEmployeeId)
    {
        var stepApprovers = await workflowStepApproverService.GetByStepIdAsync(workflowStepId);
        var activeStepApprovers = stepApprovers.Where(r => r.IsActive).OrderBy(r => r.PriorityOrder).ToList();

        if (activeStepApprovers.Count == 0)
            throw new WorkflowApproverResolutionException(workflowStepId,
                "No active step approver rules found.");

        var results = new List<ResolvedApprover>();

        foreach (var activeStepApprover in activeStepApprovers)
        {
            var resolved = activeStepApprover.WorkflowApproverType switch
            {
                WorkflowApproverType.ReportingManager =>
                    await ResolveReportingManagerAsync(activeStepApprover.Id, initiatorEmployeeId),

                WorkflowApproverType.SkipManager =>
                    await ResolveSkipManagerAsync(activeStepApprover.Id, initiatorEmployeeId),

                WorkflowApproverType.Employee =>
                    await ResolveFixedEmployeeAsync(activeStepApprover.Id, activeStepApprover.ScopeReferenceId),

                WorkflowApproverType.Designation =>
                    await ResolveByDesignationAsync(activeStepApprover.Id, activeStepApprover.ScopeTypeId, activeStepApprover.ScopeReferenceId, initiatorEmployeeId),

                // TO DO Later Implementation once Auth Microservices gets implemented.
                //WorkflowApproverType.Role =>
                //    await ResolveByRoleAsync(activeStepApprover.Id, activeStepApprover.ScopeTypeId,
                //        activeStepApprover.ScopeReferenceId, initiatorEmployeeId),

                _ => throw new WorkflowApproverResolutionException(workflowStepId,
                    $"Unknown ApproverType '{activeStepApprover.WorkflowApproverType}'.")
            };

            results.AddRange(resolved);
        }

        if (results.Count == 0)
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
        Guid approverId, Guid initiatorEmployeeId)
    {
        var manager = await employeeQueryService.GetReportingManagerAsync(initiatorEmployeeId);

        if (manager is null) return [];

        return [new ResolvedApprover { WorkflowStepApproverId = approverId, ApproverType = WorkflowApproverType.ReportingManager, ResolvedEmployeeId = manager.EmployeeId, ResolvedEmployeeName = manager.DisplayName, ResolvedDesignationId = manager.DesignationId, ResolvedDepartmentId = manager.PrimaryDepartmentId }];
    }

    private async Task<IEnumerable<ResolvedApprover>> ResolveSkipManagerAsync(
        Guid approverId, Guid initiatorEmployeeId)
    {
        // Get reporting manager first, then their reporting manager
        var manager = await employeeQueryService.GetReportingManagerAsync(initiatorEmployeeId);
        if (manager is null) return [];

        var skipManager = await employeeQueryService.GetReportingManagerAsync(manager.EmployeeId);
        if (skipManager is null) return [];

        return [new ResolvedApprover { WorkflowStepApproverId = approverId, ApproverType = WorkflowApproverType.SkipManager, ResolvedEmployeeId = skipManager.EmployeeId, ResolvedEmployeeName = skipManager.DisplayName, ResolvedDesignationId = skipManager.DesignationId, ResolvedDepartmentId = skipManager.PrimaryDepartmentId }];
    }

    private async Task<IEnumerable<ResolvedApprover>> ResolveFixedEmployeeAsync(
        Guid approverId, Guid? scopeReferenceId)
    {
        if (scopeReferenceId is null) return [];

        var emp = await employeeQueryService.GetEmployeeByIdAsync(scopeReferenceId.Value);
        if (emp is null) return [];

        return [new ResolvedApprover { WorkflowStepApproverId = approverId, ApproverType = WorkflowApproverType.Employee, ResolvedEmployeeId = emp.EmployeeId, ResolvedEmployeeName = emp.DisplayName, ResolvedDesignationId = emp.DesignationId, ResolvedDepartmentId = emp.PrimaryDepartmentId }];
    }

    private async Task<IEnumerable<ResolvedApprover>> ResolveByDesignationAsync(
        Guid approverId, Guid? scopeTypeId, Guid? scopeReferenceId, Guid initiatorEmployeeId)
    {
        // Get qualifying designation IDs for this approver rule
        var designationIds = await workflowStepApproverService.GetDesignationIdsAsync(approverId);
        if (!designationIds.Any()) return [];

        var scopeTypes = await timeQueryService.GetAllScopeTypeAsync();

        string? scopeCode = scopeTypes
            .FirstOrDefault(x => scopeTypeId.HasValue && x.Id == scopeTypeId.Value)
            ?.ScopeCode;

        // Determine scope: null ScopeReferenceId = use initiator's own scope
        Guid? resolvedScopeId = scopeReferenceId.HasValue
            ? scopeReferenceId
            : scopeTypeId.HasValue
                ? await employeeQueryService.GetScopeReferenceIdAsync(initiatorEmployeeId, scopeCode)
                : null;

        var employees = await employeeQueryService.GetEmployeesByDesignationInScopeAsync(
            designationIds, scopeCode, resolvedScopeId);

        return employees.Select(e => new ResolvedApprover { WorkflowStepApproverId = approverId, ApproverType = WorkflowApproverType.Designation, ResolvedEmployeeId = e.EmployeeId, ResolvedEmployeeName = e.DisplayName, ResolvedDesignationId = e.DesignationId, ResolvedDepartmentId = e.PrimaryDepartmentId });
    }

    // TO DO Later
    //private async Task<IEnumerable<ResolvedApprover>> ResolveByRoleAsync(
    //    short approverId, short? scopeTypeId, short? scopeReferenceId, int initiatorEmployeeId)
    //{
    //    // Role-based resolution delegates to auth schema lookup
    //    // Returns employees who hold the required role in the given scope
    //    int? resolvedScopeId = scopeReferenceId is not null
    //        ? (int)scopeReferenceId
    //        : await employeeQueryService.GetScopeReferenceIdAsync(initiatorEmployeeId, scopeTypeId);

    //    var employees = await employeeQueryService.GetEmployeesByRoleInScopeAsync(
    //        approverId, scopeTypeId, resolvedScopeId);

    //    return employees.Select(e => new ResolvedApprover(
    //        approverId,
    //        WorkflowApproverType.Role,
    //        e.EmployeeId,
    //        e.DisplayName,
    //        e.DesignationName,
    //        e.DepartmentName));
    //}        
}
