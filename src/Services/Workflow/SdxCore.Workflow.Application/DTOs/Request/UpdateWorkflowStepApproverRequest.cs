namespace SdxCore.Workflow.Application.DTOs.Request;

public record UpdateWorkflowStepApproverRequest(
    short? ScopeTypeId,
    short? ScopeReferenceId,
    short  PriorityOrder,
    bool   IsMandatory);
