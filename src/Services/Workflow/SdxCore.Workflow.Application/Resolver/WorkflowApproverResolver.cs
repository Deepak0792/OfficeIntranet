using Microsoft.Extensions.Logging;
using SdxCore.Common.Enums.Workflow;
using SdxCore.Workflow.Application.Abstractions.Resolver;
using SdxCore.Workflow.Application.Abstractions.Services;
using SdxCore.Workflow.Application.DTOs.Employee;
using SdxCore.Workflow.Application.DTOs.Resolution.Response;
using SdxCore.Workflow.Application.DTOs.Time;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Exceptions;

namespace SdxCore.Workflow.Application.Resolver;

public class WorkflowApproverResolver(
    IWorkflowStepApproverService workflowStepApproverService,
    IEmployeeQueryService employeeQueryService,
    ITimeQueryService timeQueryService,
    IWorkflowModuleService workflowModuleService,
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


    public async Task<WorkflowAssignmentSummary> ResolveDefinitionAsync(
    string moduleCode,
    string workflowCode,
    Guid initiatorEmployeeId)
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
        Dictionary<Guid, HashSet<Guid>> employeeScopes,
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

        if (assignments.Count == 0)
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
    private static Dictionary<Guid, HashSet<Guid>> BuildEmployeeScopes(
        EmployeeSummaryResponse employeeSummary,
        IEnumerable<ScopeTypeResponse> scopeTypeResponses)
    {
        // 3. Build ScopeCode → ScopeTypeId lookup
        var scopeTypeMap = scopeTypeResponses
            .ToDictionary(s => s.ScopeCode, s => s.Id, StringComparer.OrdinalIgnoreCase);

        var scopes = new Dictionary<Guid, HashSet<Guid>>();

        void Add(string scopeCode, Guid? referenceId)
        {
            if (referenceId is null) return;
            if (!scopeTypeMap.TryGetValue(scopeCode, out var scopeTypeId)) return;
            _ = scopes.TryAdd(scopeTypeId, []);
            _ = scopes[scopeTypeId].Add(referenceId.Value);
        }

        Add(ScopeTypeCodes.Employee, employeeSummary.EmployeeId);
        Add(ScopeTypeCodes.Team, employeeSummary.PrimaryTeamId);
        Add(ScopeTypeCodes.Department, employeeSummary.PrimaryDepartmentId);
        Add(ScopeTypeCodes.Office, employeeSummary.PrimaryLocationId);
        Add(ScopeTypeCodes.LegalEntity, employeeSummary.PrimaryLegalEntityId);
        Add(ScopeTypeCodes.Global, employeeSummary.PrimaryLegalEntityId); // GLOBAL always uses ref=1

        return scopes;
    }
}
