namespace SdxCore.Workflow.Application.DTOs.StepApprover.Response;

public record WorkflowStepApproverResponse(
    Guid Id,
    Guid WorkflowStepId,
    string WorkflowApproverType,
    Guid? ScopeTypeId,
    Guid? ScopeReferenceId,
    short PriorityOrder,
    bool IsMandatory,
    bool IsActive,
    IEnumerable<WorkflowStepApproverDesignationResponse>? Designations);
