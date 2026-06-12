using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowTask : BaseAuditEntity<Guid>
{
    public Guid WorkflowInstanceId { get; set; }
    public Guid WorkflowStepId { get; set; }

    /// <summary>The approver resolution rule that generated this task.</summary>
    public Guid WorkflowStepApproverId { get; set; }

    /// <summary>Cross-schema FK to employee.Employee — the resolved approver assigned to this task.</summary>
    public Guid AssignedToEmployeeId { get; set; }

    /// <summary>Cross-schema FK to employee.Employee — set when task was delegated from another employee.</summary>
    public Guid? DelegatedFromEmployeeId { get; set; }

    /// <summary>Lookup code from shared.StatusLookup under group WORKFLOW_TASK_STATUS.</summary>
    public required string TaskStatus { get; set; }

    public string? Remarks { get; set; }

    /// <summary>Set when this task is a delegation child — points to the original task.</summary>
    public Guid? ParentWorkflowTaskId { get; set; }

    public DateTime AssignedAt { get; set; } = DateTime.UtcNow;

    /// <summary>Computed from step EscalationAfterHours at task creation time.</summary>
    public DateTime? DueAt { get; set; }

    public DateTime? ActionAt { get; set; }

    /// <summary>Cross-schema FK to employee.Employee — the employee who took the action.</summary>
    public Guid ActionBy { get; set; }

    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────
    public WorkflowInstance Instance { get; set; } = null!;
    public WorkflowStep Step { get; set; } = null!;
    public WorkflowStepApprover StepApprover { get; set; } = null!;

    /// <summary>Parent task in a delegation chain (null if this is the original task).</summary>
    public WorkflowTask? ParentTask { get; set; }

    /// <summary>Child tasks delegated from this task.</summary>
    public ICollection<WorkflowTask> ChildTasks { get; set; } = [];
}