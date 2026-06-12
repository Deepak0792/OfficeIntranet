using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowAssignment : BaseAuditEntity<Guid>
{
    public Guid WorkflowDefinitionId { get; set; }

    /// <summary>Cross-schema FK to time.ScopeType — the routing scope level (e.g. DEPARTMENT, LEGAL_ENTITY).</summary>
    public Guid ScopeTypeId { get; set; }

    /// <summary>Entity ID at the routing scope (e.g. DepartmentId when ScopeType=DEPARTMENT). Nullable — NULL means global scope.</summary>
    public Guid? ScopeReferenceId { get; set; }

    public DateOnly EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
    public short PriorityOrder { get; set; } = 1;
    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────
    public WorkflowDefinition Definition { get; set; } = null!;
}
