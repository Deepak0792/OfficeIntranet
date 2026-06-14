using SdxCore.Workflow.Application.DTOs.StepApprover.Response;

namespace SdxCore.Workflow.Application.DTOs.Step.Response;

public sealed class WorkflowStepResponse
{
    public Guid Id { get; set; }
    public Guid WorkflowDefinitionId { get; set; }
    public short StepNo { get; set; }
    public string StepName { get; set; } = default!;
    public string WorkflowStepType { get; set; } = default!;
    public bool IsFinalStep { get; set; }
    public bool AllowDelegation { get; set; }
    public int? EscalationAfterHours { get; set; }
    public bool IsActive { get; set; }
    public IEnumerable<WorkflowStepApproverResponse>? Approvers { get; set; }
}
