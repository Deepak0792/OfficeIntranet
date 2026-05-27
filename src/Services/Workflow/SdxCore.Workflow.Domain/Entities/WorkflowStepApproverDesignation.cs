namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowStepApproverDesignation : BaseEntity
{
    public short Id { get; set; }
    public short WorkflowStepApproverId { get; set; }
    public short DesignationId { get; set; }

    public WorkflowStepApprover? StepApprover { get; set; }
}
