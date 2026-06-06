using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowStepApproverDesignation : BaseAuditEntity<short>
{
    public short WorkflowStepApproverId { get; set; }
    public short DesignationId { get; set; }   // FK → time.Designation
    public bool IsActive { get; set; } = true;

    // Navigation
    public WorkflowStepApprover Approver { get; set; } = null!;
}
