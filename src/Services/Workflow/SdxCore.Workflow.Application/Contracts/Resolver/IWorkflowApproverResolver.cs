using SdxCore.Workflow.Application.DTOs.Resolver;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Application.Contracts.Resolver;

public interface IWorkflowApproverResolver
{
    /// <summary>
    /// Returns resolved employee IDs for a given step + initiator.
    /// Handles all ApproverType strategies:
    ///   REPORTING_MANAGER → follows EmployeeRelationship
    ///   DESIGNATION       → finds employees with qualifying designation in scope
    ///   EMPLOYEE          → directly returns ScopeReferenceId as employee id
    ///   ROLE              → finds employees with matching role in scope (auth schema)
    ///   SKIP_MANAGER      → skip-level manager from org hierarchy
    /// </summary>
    Task<IEnumerable<ResolvedApprover>> ResolveApproverAsync(
        Guid workflowStepId,
        Guid initiatorEmployeeId);

    Task<WorkflowAssignmentSummary> ResolveDefinitionAsync(
        string moduleCode,
        string workflowCode,
        Guid initiatorEmployeeId);
}
