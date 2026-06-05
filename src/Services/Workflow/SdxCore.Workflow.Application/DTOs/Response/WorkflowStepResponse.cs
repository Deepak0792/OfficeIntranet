namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowStepResponse(
    short  Id,
    short  WorkflowDefinitionId,
    short  StepNo,
    string StepName,
    string WorkflowStepType,
    bool   IsFinalStep,
    bool   AllowDelegation,
    int?   EscalationAfterHours,
    bool   IsActive,
    IEnumerable<WorkflowStepApproverResponse>? Approvers);
