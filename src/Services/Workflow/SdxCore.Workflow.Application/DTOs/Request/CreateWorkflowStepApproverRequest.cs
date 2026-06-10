namespace SdxCore.Workflow.Application.DTOs.Request;

public record CreateWorkflowStepApproverRequest(
    string WorkflowApproverType,   // REPORTING_MANAGER | DESIGNATION | EMPLOYEE | ROLE | SKIP_MANAGER
    Guid? ScopeTypeId,
    Guid? ScopeReferenceId,
    short  PriorityOrder,
    bool   IsMandatory);
