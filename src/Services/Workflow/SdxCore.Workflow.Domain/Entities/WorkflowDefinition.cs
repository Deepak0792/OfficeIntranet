using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowDefinition : BaseAuditEntity<short>
{
    public short WorkflowModuleId { get; set; }
    public string WorkflowCode { get; set; } = null!;
    public string WorkflowName { get; set; } = null!;
    public short VersionNo { get; set; } = 1;
    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation
    public WorkflowModule Module { get; set; } = null!;
    public ICollection<WorkflowStep> Steps { get; set; } = [];
    public ICollection<WorkflowAssignment> Assignments { get; set; } = [];
}
