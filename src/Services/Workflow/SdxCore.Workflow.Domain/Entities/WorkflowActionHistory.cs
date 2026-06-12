using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowActionHistory : BaseAuditEntity<Guid>
{
    public Guid WorkflowInstanceId { get; set; }

    /// <summary>NULL for system-generated actions (e.g. auto-escalation).</summary>
    public Guid? WorkflowTaskId { get; set; }

    public Guid? WorkflowStepId { get; set; }

    /// <summary>Lookup code from shared.StatusLookup under group WORKFLOW_ACTION_TYPE.</summary>
    public required string WorkflowActionType { get; set; }

    public string? Remarks { get; set; }
    public string? FromWorkflowStatus { get; set; }
    public string? ToWorkflowStatus { get; set; }
    public bool IsActive { get; set; } = true;

    /// <summary>Cross-schema FK to employee.Employee — the employee who performed the action.</summary>
    public Guid ActionBy { get; set; }

    public DateTime ActionAt { get; set; }

    // ── Intra-schema navigation properties ────────────────────────────────────
    public WorkflowInstance Instance { get; set; } = null!;

    /// <summary>The task that was acted on (null for system actions).</summary>
    public WorkflowTask? Task { get; set; }

    public WorkflowStep? Step { get; set; }
}
