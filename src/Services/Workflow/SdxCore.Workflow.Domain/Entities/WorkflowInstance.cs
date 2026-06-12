using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowInstance : BaseAuditEntity<Guid>
{
    public Guid WorkflowDefinitionId { get; set; }
    public Guid WorkflowModuleId { get; set; }
    public Guid ReferenceTransactionId { get; set; }

    /// <summary>NULL when the instance is completed or cancelled.</summary>
    public Guid? CurrentWorkflowStepId { get; set; }

    /// <summary>Lookup code from shared.StatusLookup under group WORKFLOW_STATUS.</summary>
    public required string WorkflowStatus { get; set; }

    public DateTime? CompletedAt { get; set; }

    /// <summary>Cross-schema FK to employee.Employee — the employee who completed/closed the instance.</summary>
    public Guid? CompletedBy { get; set; }

    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────
    public WorkflowDefinition Definition { get; set; } = null!;
    public WorkflowModule Module { get; set; } = null!;
    public WorkflowStep? CurrentStep { get; set; }

    /// <summary>All tasks generated for this instance (one per resolved approver per step).</summary>
    public ICollection<WorkflowTask> Tasks { get; set; } = [];

    /// <summary>Immutable audit log of all state transitions for this instance.</summary>
    public ICollection<WorkflowActionHistory> History { get; set; } = [];
}
