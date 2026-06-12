using SdxCore.Workflow.Application.DTOs.StepApprover.Response;

namespace SdxCore.Workflow.Application.DTOs.Step.Response;

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
