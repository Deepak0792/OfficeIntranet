using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowStepApproverDesignation : BaseAuditEntity<Guid>
{
    public Guid WorkflowStepApproverId { get; set; }

    /// <summary>Cross-schema FK to time.Designation — stored as ID only, no nav prop.</summary>
    public Guid DesignationId { get; set; }

    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────
    public WorkflowStepApprover Approver { get; set; } = null!;
}
