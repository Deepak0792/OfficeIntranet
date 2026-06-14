using SdxCore.Common.Enums.Workflow;
using SdxCore.Common.Helpers;
using SdxCore.Workflow.Application.Abstractions.Resolver;
using SdxCore.Workflow.Application.Abstractions.Services;
using SdxCore.Workflow.Application.DTOs.Definition.Response;
using SdxCore.Workflow.Application.DTOs.Employee;
using SdxCore.Workflow.Application.DTOs.Resolution.Request;
using SdxCore.Workflow.Application.DTOs.Resolution.Response;
using SdxCore.Workflow.Application.DTOs.Time;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Exceptions;

namespace SdxCore.Workflow.Application.Services;

public class WorkflowResolutionService(
    IEmployeeQueryService employeeQueryService,
    ITimeQueryService timeQueryService,
    IWorkflowModuleService workflowModuleService,
    IWorkflowDefinitionService workflowDefinitionService,
    IWorkflowApproverResolver resolver) : IWorkflowResolutionService
{
    public async Task<IEnumerable<PreviewApproversResponse>> PreviewApproversAsync(
        PreviewApproversRequest request)
    {
        var resolved = await resolver.ResolveApproverAsync(request.WorkflowStepId, request.InitiatorEmployeeId);
        return PropertyMapper.MapList<ResolvedApprover, PreviewApproversResponse>(resolved);
    }

    public async Task<WorkflowAssignmentSummary> ResolveWorkflowDefinitionAsync(string moduleCode, string workflowCode, Guid initiatorEmployeeId, CancellationToken cancellationToken = default)
    {
        var employeeSummary = await employeeQueryService.GetEmployeeByIdAsync(initiatorEmployeeId, cancellationToken)
            ?? throw new InvalidOperationException($"Employee service returned null for Employee Id {initiatorEmployeeId}");

        var scopeTypes = await timeQueryService.GetAllScopeTypeAsync(cancellationToken);

        if (scopeTypes == null || !scopeTypes.Any())
            throw new InvalidOperationException("Scope types are not configured");

        var employeeScope = BuildEmployeeScopes(employeeSummary, scopeTypes);

        if (employeeScope is null)
            throw new EmployeeScopeResolutionException(initiatorEmployeeId);

        // 2. Query workflow assignments from view
        var workflow = await ResolveWorkflowDefinitionAsync(moduleCode, workflowCode, scopeTypes, employeeScope, null, cancellationToken);

        // 3. Fallback / validation
        if (workflow is null)
        {
            throw new WorkflowResolutionException(initiatorEmployeeId, moduleCode, workflowCode);
        }

        return workflow;
    }

    public async Task<WorkflowAssignmentSummary> ResolveWorkflowDefinitionAsync(string moduleCode, string workflowCode, Guid employeeId, DateOnly? effectiveDate, CancellationToken cancellationToken = default)
    {
        var employeeSummary = await employeeQueryService.GetEmployeeByIdAsync(employeeId, cancellationToken)
              ?? throw new InvalidOperationException($"Employee service returned null for Employee Id {employeeId}");

        var scopeTypes = await timeQueryService.GetAllScopeTypeAsync(cancellationToken);

        if (scopeTypes == null || !scopeTypes.Any())
            throw new InvalidOperationException("Scope types are not configured");

        var employeeScope = BuildEmployeeScopes(employeeSummary, scopeTypes);

        if (employeeScope is null)
            throw new EmployeeScopeResolutionException(employeeId);

        // 2. Query workflow assignments from view
        var workflow = await ResolveWorkflowDefinitionAsync(moduleCode, workflowCode, scopeTypes, employeeScope, effectiveDate, cancellationToken);

        // 3. Fallback / validation
        if (workflow is null)
        {
            throw new WorkflowResolutionException(employeeId, moduleCode, workflowCode);
        }

        return workflow;
    }

    public async Task<WorkflowDefinitionResponse> ResolveDefinitionByEffectiveDateAsync(string moduleCode, string workflowCode, Guid employeeId, DateOnly? effectiveDate, CancellationToken cancellationToken = default)
    {
        var workflow = await ResolveWorkflowDefinitionAsync(moduleCode, workflowCode, employeeId, effectiveDate, cancellationToken);
        return await workflowDefinitionService.GetByIdAsync(workflow.WorkflowDefinitionId, cancellationToken);
    }


    /// <summary>
    /// Maps each ScopeTypeId - ReferenceIds the employee belongs to.
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
        DateOnly? effectiveDate = null,
        CancellationToken cancellationToken = default)
    {
        var today = effectiveDate ?? DateOnly.FromDateTime(DateTime.UtcNow);
        // 1. Fetch ALL assignments for this module
        var allAssignments = await workflowModuleService
            .GetWorkflowAssignmentsAsync(moduleCode, cancellationToken);

        // 2. Filter to the specific leave-type workflow
        //    e.g. STANDARD_LEAVE_V1, STANDARD_LEAVE_V2, EMERGENCY_LEAVE_V1
        var assignments = allAssignments
            .Where(a => string.Equals(a.WorkflowCode, workflowCode, StringComparison.OrdinalIgnoreCase)
                && a.EffectiveFrom <= today && a.EffectiveTo == null || a.EffectiveTo >= today)
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
}