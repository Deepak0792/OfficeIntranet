namespace SdxCore.Workflow.Application.DTOs.StepApprover.Request;

public sealed class UpdateWorkflowStepApproverRequest
{
    public Guid? ScopeTypeId { get; set; }
    public Guid? ScopeReferenceId { get; set; }
    public short PriorityOrder { get; set; }
    public bool IsMandatory { get; set; }
}
