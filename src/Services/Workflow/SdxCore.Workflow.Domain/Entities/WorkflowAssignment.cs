using System;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowAssignment : BaseEntity
{
    public short Id { get; set; }
    public short WorkflowDefinitionId { get; set; }
    public short ScopeTypeId { get; set; }
    public short ScopeReferenceId { get; set; }
    public DateTime EffectiveFrom { get; set; }
    public DateTime? EffectiveTo { get; set; }
    public short PriorityOrder { get; set; } = 1;

    public WorkflowDefinition? Definition { get; set; }
}
