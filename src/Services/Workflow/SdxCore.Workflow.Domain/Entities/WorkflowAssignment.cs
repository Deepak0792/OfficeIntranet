using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowAssignment : BaseEntity<short>
{
    public short WorkflowDefinitionId { get; set; }
    public short ScopeTypeId { get; set; }   // FK → time.ScopeType (routing scope)
    public short ScopeReferenceId { get; set; }   // Entity id at routing scope
    public DateOnly EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
    public short PriorityOrder { get; set; } = 1;
    public bool IsActive { get; set; } = true;

    // Navigation
    public WorkflowDefinition Definition { get; set; } = null!;
}
