using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowStepApproverDesignation : BaseAuditEntity<Guid>
{
    public Guid WorkflowStepApproverId { get; set; }
    public Guid DesignationId { get; set; }   // FK → time.Designation
    public bool IsActive { get; set; } = true;

    // Navigation
    public WorkflowStepApprover Approver { get; set; } = null!;
}
