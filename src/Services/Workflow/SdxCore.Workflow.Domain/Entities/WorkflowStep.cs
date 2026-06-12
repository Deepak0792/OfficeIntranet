using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowStep : BaseAuditEntity<Guid>
{
    public Guid WorkflowDefinitionId { get; set; }
    public short StepNo { get; set; }
    public required string StepName { get; set; }

    /// <summary>Lookup code from shared.StatusLookup under group WORKFLOW_STEP_TYPE (e.g. APPROVAL, REVIEW, NOTIFICATION, FYI).</summary>
    public required string WorkflowStepType { get; set; }

    public bool IsFinalStep { get; set; } = false;
    public bool AllowDelegation { get; set; } = true;
    public int? EscalationAfterHours { get; set; }
    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────
    public WorkflowDefinition Definition { get; set; } = null!;

    /// <summary>Approver resolution rules for this step.</summary>
    public ICollection<WorkflowStepApprover> Approvers { get; set; } = [];
}
