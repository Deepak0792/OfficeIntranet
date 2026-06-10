namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowStepResponse(
    Guid Id,
    Guid WorkflowDefinitionId,
    short StepNo,
    string StepName,
    string WorkflowStepType,
    bool IsFinalStep,
    bool AllowDelegation,
    int? EscalationAfterHours,
    bool IsActive,
    IEnumerable<WorkflowStepApproverResponse>? Approvers);
