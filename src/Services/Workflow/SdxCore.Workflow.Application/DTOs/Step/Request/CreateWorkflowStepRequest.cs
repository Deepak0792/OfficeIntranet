namespace SdxCore.Workflow.Application.DTOs.Step.Request;

public sealed class CreateWorkflowStepRequest
{
    public short StepNo { get; set; }
    public string StepName { get; set; } = default!;
    public string WorkflowStepType { get; set; } = default!; // APPROVAL | REVIEW | NOTIFICATION | AUTO_APPROVAL
    public bool IsFinalStep { get; set; }
    public bool AllowDelegation { get; set; }
    public int? EscalationAfterHours { get; set; }
}
