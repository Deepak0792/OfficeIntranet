namespace SdxCore.Workflow.Application.DTOs.Request;

public record UpdateWorkflowStepApproverRequest(
    Guid? ScopeTypeId,
    Guid? ScopeReferenceId,
    short  PriorityOrder,
    bool   IsMandatory);
