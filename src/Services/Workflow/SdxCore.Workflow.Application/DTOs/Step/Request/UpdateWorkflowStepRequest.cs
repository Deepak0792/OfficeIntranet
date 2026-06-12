namespace SdxCore.Workflow.Application.DTOs.Step.Request;

public record UpdateWorkflowStepRequest(
    string StepName,
    string WorkflowStepType,
    bool IsFinalStep,
    bool AllowDelegation,
    int? EscalationAfterHours);
