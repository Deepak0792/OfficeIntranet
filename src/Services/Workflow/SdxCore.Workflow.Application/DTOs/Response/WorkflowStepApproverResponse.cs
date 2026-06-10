namespace SdxCore.Workflow.Application.DTOs.Response;

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
