namespace SdxCore.Workflow.Application.DTOs.Request;

public record UpdateWorkflowStepRequest(
    string StepName,
    string WorkflowStepType,
    bool   IsFinalStep,
    bool   AllowDelegation,
    int?   EscalationAfterHours);
