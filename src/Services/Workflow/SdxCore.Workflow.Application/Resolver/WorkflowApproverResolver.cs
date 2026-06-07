using Microsoft.AspNetCore.Cors.Infrastructure;
using Microsoft.Extensions.Logging;
using SdxCore.Workflow.Application.Contracts.Resolver;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Resolver;
using SdxCore.Workflow.Application.DTOs.Response;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Enums;
using SdxCore.Workflow.Domain.Exceptions;
using SdxCore.Workflow.Domain.Repositories;

namespace SdxCore.Workflow.Application.Resolver;

public class WorkflowApproverResolver(
    IWorkflowStepApproverService workflowStepApproverService,
    IEmployeeQueryService employeeQueryService,
    ITimeQueryService timeQueryService,
    IWorkflowModuleService workflowModuleService,
    ILogger<WorkflowApproverResolver> logger) : IWorkflowApproverResolver
{
    public async Task<IEnumerable<ResolvedApprover>> ResolveApproverAsync(
        short workflowStepId, int initiatorEmployeeId)
    {
        var stepApprovers = await workflowStepApproverService.GetByStepIdAsync(workflowStepId);
        var activeStepApprovers = stepApprovers.Where(r => r.IsActive).OrderBy(r => r.PriorityOrder).ToList();

        if (!activeStepApprovers.Any())
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


    public async Task<WorkflowAssignmentSummary> ResolveDefinitionAsync(
    string moduleCode,
    string workflowCode,
    int initiatorEmployeeId)
    {
        var employeeSummary = await employeeQueryService.GetEmployeeByIdAsync(initiatorEmployeeId)
            ?? throw new InvalidOperationException($"Employee service returned null for Employee Id {initiatorEmployeeId}");

        var scopeTypes = await timeQueryService.GetAllScopeTypeAsync();

        if (scopeTypes == null || !scopeTypes.Any())
            throw new InvalidOperationException("Scope types are not configured");

        var employeeScope = BuildEmployeeScopes(employeeSummary, scopeTypes);

        if (employeeScope is null)
            throw new EmployeeScopeResolutionException(initiatorEmployeeId);

        // 2. Query workflow assignments from view
        var workflow = await ResolveWorkflowDefinitionAsync(moduleCode, workflowCode, scopeTypes, employeeScope);

        // 3. Fallback / validation
        if (workflow is null)
        {
            throw new WorkflowResolutionException(initiatorEmployeeId, moduleCode, workflowCode);
        }

        return workflow;
    }
    // ── Resolution strategies ────────────────────────────────

    private async Task<IEnumerable<ResolvedApprover>> ResolveReportingManagerAsync(
        short approverId, int initiatorEmployeeId)
    {
        var manager = await employeeQueryService.GetReportingManagerAsync(initiatorEmployeeId);

        if (manager is null) return [];

        return [new ResolvedApprover(
            approverId,
            WorkflowApproverType.ReportingManager,
            manager.EmployeeId,
            manager.DisplayName,
            manager.DesignationId,
            manager.PrimaryDepartmentId)];
    }

    private async Task<IEnumerable<ResolvedApprover>> ResolveSkipManagerAsync(
        short approverId, int initiatorEmployeeId)
    {
        // Get reporting manager first, then their reporting manager
        var manager = await employeeQueryService.GetReportingManagerAsync(initiatorEmployeeId);
        if (manager is null) return [];

        var skipManager = await employeeQueryService.GetReportingManagerAsync(manager.EmployeeId);
        if (skipManager is null) return [];

        return [new ResolvedApprover(
            approverId,
            WorkflowApproverType.SkipManager,
            skipManager.EmployeeId,
            skipManager.DisplayName,
            skipManager.DesignationId,
            skipManager.PrimaryDepartmentId)];
    }

    private async Task<IEnumerable<ResolvedApprover>> ResolveFixedEmployeeAsync(
        short approverId, short? scopeReferenceId)
    {
        if (scopeReferenceId is null) return [];

        var emp = await employeeQueryService.GetEmployeeByIdAsync((int)scopeReferenceId);
        if (emp is null) return [];

        return [new ResolvedApprover(
            approverId,
            WorkflowApproverType.Employee,
            emp.EmployeeId,
            emp.DisplayName,
            emp.DesignationId,
            emp.PrimaryDepartmentId)];
    }

    private async Task<IEnumerable<ResolvedApprover>> ResolveByDesignationAsync(
        short approverId, short? scopeTypeId, short? scopeReferenceId, int initiatorEmployeeId)
    {
        // Get qualifying designation IDs for this approver rule
        var designationIds = await workflowStepApproverService.GetDesignationIdsAsync(approverId);
        if (!designationIds.Any()) return [];

        // Determine scope: null ScopeReferenceId = use initiator's own scope
        int? resolvedScopeId = scopeReferenceId.HasValue
            ? (int)scopeReferenceId
            : scopeTypeId.HasValue
                ? await employeeQueryService.GetScopeReferenceIdAsync(initiatorEmployeeId, scopeTypeId)
                : null;

        var employees = await employeeQueryService.GetEmployeesByDesignationInScopeAsync(
            designationIds, scopeTypeId, resolvedScopeId);

        return employees.Select(e => new ResolvedApprover(
            approverId,
            WorkflowApproverType.Designation,
            e.EmployeeId,
            e.DisplayName,
            e.DesignationId,
            e.PrimaryDepartmentId));
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

    /// <summary>
    /// Resolves the correct WorkflowAssignment for a given employee and leave type.
    ///
    /// Resolution logic:
    ///   1. Filter assignments by moduleCode + workflowCode (leave type)
    ///   2. Walk scope hierarchy most-specific → most-general
    ///      EMPLOYEE(7) → TEAM(6) → DEPARTMENT(5) → OFFICE(4) → LEGAL_ENTITY(3) → COUNTRY(2) → GLOBAL(1)
    ///   3. First match at the most-specific level wins
    ///   4. PriorityOrder breaks ties at the same scope level
    ///
    /// Example:
    ///   moduleCode   = "LEAVE_REQUEST"
    ///   workflowCode = "STANDARD_LEAVE_V2"   ← ICU dept workflow
    ///   employee     = DeptId=5 (ICU), TeamId=12
    ///
    ///   Assignments for STANDARD_LEAVE_V2:
    ///     A1 → DEPARTMENT/5 → priority 1   ← matches ICU dept → ✅ returns A1
    ///     A2 → GLOBAL/1     → priority 1   ← fallback, not reached
    /// </summary>
    private async Task<WorkflowAssignmentSummary?> ResolveWorkflowDefinitionAsync(
        string moduleCode,
        string workflowCode,
        IEnumerable<ScopeTypeResponse> scopeTypeResponses,
        Dictionary<short, HashSet<int>> employeeScopes,
        CancellationToken cancellationToken = default)
    {
        // 1. Fetch ALL assignments for this module
        var allAssignments = await workflowModuleService
            .GetWorkflowAssignmentsAsync(moduleCode, cancellationToken);

        // 2. Filter to the specific leave-type workflow
        //    e.g. STANDARD_LEAVE_V1, STANDARD_LEAVE_V2, EMERGENCY_LEAVE_V1
        var assignments = allAssignments
            .Where(a => string.Equals(a.WorkflowCode, workflowCode,
                                      StringComparison.OrdinalIgnoreCase))
            .ToList();

        if (!assignments.Any())
            return null; // No assignment configured for this workflow code

        // 3. Build ScopeCode → ScopeTypeId lookup
        var scopeTypeMap = scopeTypeResponses
            .ToDictionary(s => s.ScopeCode, s => s.Id, StringComparer.OrdinalIgnoreCase);

        // 5. Walk hierarchy from most specific to most general
        var orderedScopeTypes = scopeTypeResponses
            .Where(s => s.IsActive)
            .OrderByDescending(s => s.HierarchyLevel); // EMPLOYEE=7 first, GLOBAL=1 last

        foreach (var scopeType in orderedScopeTypes)
        {
            if (!employeeScopes.TryGetValue(scopeType.Id, out var employeeReferenceIds))
                continue;

            var match = assignments
                .Where(a =>
                    a.ScopeTypeId == scopeType.Id &&
                    employeeReferenceIds.Contains(a.ScopeReferenceId))
                .OrderBy(a => a.PriorityOrder)
                .FirstOrDefault();

            if (match is not null)
                return match;
        }

        return null; // No matching scope assignment found for this employee
    }

    /// <summary>
    /// Maps each ScopeTypeId → ReferenceIds the employee belongs to.
    /// Uses fields already on EmployeeSummaryResponse — zero extra DB calls.
    /// </summary>
    private static Dictionary<short, HashSet<int>> BuildEmployeeScopes(
        EmployeeSummaryResponse employeeSummary,
        IEnumerable<ScopeTypeResponse> scopeTypeResponses)
    {
        // 3. Build ScopeCode → ScopeTypeId lookup
        var scopeTypeMap = scopeTypeResponses
            .ToDictionary(s => s.ScopeCode, s => s.Id, StringComparer.OrdinalIgnoreCase);

        var scopes = new Dictionary<short, HashSet<int>>();

        void Add(string scopeCode, int? referenceId)
        {
            if (referenceId is null) return;
            if (!scopeTypeMap.TryGetValue(scopeCode, out var scopeTypeId)) return;
            scopes.TryAdd(scopeTypeId, new HashSet<int>());
            scopes[scopeTypeId].Add(referenceId.Value);
        }

        Add(ScopeTypeCodes.Employee, employeeSummary.EmployeeId);
        Add(ScopeTypeCodes.Team, employeeSummary.PrimaryTeamId);
        Add(ScopeTypeCodes.Department, employeeSummary.PrimaryDepartmentId);
        Add(ScopeTypeCodes.Office, employeeSummary.PrimaryLocationId);
        Add(ScopeTypeCodes.LegalEntity, employeeSummary.PrimaryLegalEntityId);
        Add(ScopeTypeCodes.Global, 1); // GLOBAL always uses ref=1

        return scopes;
    }
}
