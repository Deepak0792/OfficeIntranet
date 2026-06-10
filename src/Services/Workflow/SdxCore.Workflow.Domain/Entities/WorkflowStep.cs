using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowStep : BaseAuditEntity<Guid>
{
    public Guid WorkflowDefinitionId { get; set; }
    public short StepNo { get; set; }
    public string StepName { get; set; } = null!;
    public string WorkflowStepType { get; set; } = null!;
    public bool IsFinalStep { get; set; } = false;
    public bool AllowDelegation { get; set; } = true;
    public int? EscalationAfterHours { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation
    public WorkflowDefinition Definition { get; set; } = null!;
    public ICollection<WorkflowStepApprover> Approvers { get; set; } = [];
}
