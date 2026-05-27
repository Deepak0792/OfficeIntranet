using System.Collections.Generic;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowDefinition : BaseEntity
{
    public short Id { get; set; }
    public short WorkflowModuleId { get; set; }
    public string WorkflowCode { get; set; } = string.Empty;
    public string WorkflowName { get; set; } = string.Empty;
    public short VersionNo { get; set; } = 1;
    public string? Description { get; set; }

    public WorkflowModule? Module { get; set; }
    public ICollection<WorkflowStep> Steps { get; set; } = new List<WorkflowStep>();
    public ICollection<WorkflowAssignment> Assignments { get; set; } = new List<WorkflowAssignment>();
    public ICollection<WorkflowInstance> Instances { get; set; } = new List<WorkflowInstance>();
}
