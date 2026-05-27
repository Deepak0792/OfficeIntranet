using System.Collections.Generic;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowModule : BaseEntity
{
    public short Id { get; set; }
    public string ModuleCode { get; set; } = string.Empty;
    public string ModuleName { get; set; } = string.Empty;
    public string EntityName { get; set; } = string.Empty;

    public ICollection<WorkflowDefinition> Definitions { get; set; } = new List<WorkflowDefinition>();
    public ICollection<WorkflowInstance> Instances { get; set; } = new List<WorkflowInstance>();
}
