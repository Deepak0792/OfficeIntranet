using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowStepApprover : BaseAuditEntity<Guid>
{
    public Guid WorkflowStepId { get; set; }

    /// <summary>Lookup code from shared.StatusLookup under group WORKFLOW_APPROVER_TYPE (e.g. REPORTING_MANAGER, DESIGNATION, EMPLOYEE).</summary>
    public required string WorkflowApproverType { get; set; }

    /// <summary>Cross-schema FK to time.ScopeType — defines the scope level for approver resolution.</summary>
    public Guid? ScopeTypeId { get; set; }

    /// <summary>Entity ID within the ScopeType level (e.g. DepartmentId when ScopeType=DEPARTMENT).</summary>
    public Guid? ScopeReferenceId { get; set; }

    public short PriorityOrder { get; set; } = 1;
    public bool IsMandatory { get; set; } = true;
    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────
    public WorkflowStep Step { get; set; } = null!;

    /// <summary>Qualifying designations for this approver rule (used when ApproverType=DESIGNATION).</summary>
    public ICollection<WorkflowStepApproverDesignation> Designations { get; set; } = [];
}
