namespace SdxCore.Workflow.Application.DTOs.StepApprover.Request;

public record UpdateWorkflowStepApproverRequest(
    Guid? ScopeTypeId,
    Guid? ScopeReferenceId,
    short PriorityOrder,
    bool IsMandatory);
