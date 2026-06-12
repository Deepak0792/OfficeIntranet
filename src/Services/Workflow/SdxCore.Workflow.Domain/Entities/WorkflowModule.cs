using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowModule : BaseAuditEntity<Guid>
{
    public required string ModuleCode { get; set; }
    public required string ModuleName { get; set; }

    /// <summary>The database schema that owns the entity tracked by this module (e.g. "employee", "leave").</summary>
    public required string Schema { get; set; }

    /// <summary>Logical entity name within the schema (e.g. "LeaveRequest", "ExpenseClaim").</summary>
    public required string EntityName { get; set; }

    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────

    /// <summary>Workflow definitions belonging to this module.</summary>
    public ICollection<WorkflowDefinition> Definitions { get; set; } = [];

    /// <summary>All workflow instances created under this module.</summary>
    public ICollection<WorkflowInstance> Instances { get; set; } = [];
}
