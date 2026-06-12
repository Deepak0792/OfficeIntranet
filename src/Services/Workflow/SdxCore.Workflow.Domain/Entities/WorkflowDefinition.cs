using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowDefinition : BaseAuditEntity<Guid>
{
    public Guid WorkflowModuleId { get; set; }
    public required string WorkflowCode { get; set; }
    public required string WorkflowName { get; set; }
    public short VersionNo { get; set; } = 1;
    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────

    /// <summary>The module this workflow definition belongs to.</summary>
    public WorkflowModule Module { get; set; } = null!;

    /// <summary>Ordered steps within this workflow definition.</summary>
    public ICollection<WorkflowStep> Steps { get; set; } = [];

    /// <summary>Org-scope assignments that route transactions to this definition.</summary>
    public ICollection<WorkflowAssignment> Assignments { get; set; } = [];

    /// <summary>All runtime instances created from this definition.</summary>
    public ICollection<WorkflowInstance> Instances { get; set; } = [];
}
