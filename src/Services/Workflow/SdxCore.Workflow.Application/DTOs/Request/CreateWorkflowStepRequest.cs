namespace SdxCore.Workflow.Application.DTOs.Request;

public record CreateWorkflowStepRequest(
    short  StepNo,
    string StepName,
    string WorkflowStepType,   // APPROVAL | REVIEW | NOTIFICATION | AUTO_APPROVAL
    bool   IsFinalStep,
    bool   AllowDelegation,
    int?   EscalationAfterHours);
