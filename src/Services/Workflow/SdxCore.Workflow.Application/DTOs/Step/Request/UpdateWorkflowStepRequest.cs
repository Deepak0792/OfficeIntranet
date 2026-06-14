namespace SdxCore.Workflow.Application.DTOs.Step.Request;

public sealed class UpdateWorkflowStepRequest
{
    public string StepName { get; set; } = default!;
    public string WorkflowStepType { get; set; } = default!;
    public bool IsFinalStep { get; set; }
    public bool AllowDelegation { get; set; }
    public int? EscalationAfterHours { get; set; }
}
