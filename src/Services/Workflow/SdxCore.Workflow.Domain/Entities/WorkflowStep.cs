using System.Collections.Generic;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowStep : BaseEntity
{
    public short Id { get; set; }
    public short WorkflowDefinitionId { get; set; }
    public short StepNo { get; set; }
    public string StepName { get; set; } = string.Empty;
    public string WorkflowStepType { get; set; } = string.Empty;
    public bool IsFinalStep { get; set; } = false;
    public bool AllowDelegation { get; set; } = true;
    public int? EscalationAfterHours { get; set; }

    public WorkflowDefinition? Definition { get; set; }
    public ICollection<WorkflowStepApprover> Approvers { get; set; } = new List<WorkflowStepApprover>();
    public ICollection<WorkflowInstance> CurrentInstances { get; set; } = new List<WorkflowInstance>();
    public ICollection<WorkflowTask> Tasks { get; set; } = new List<WorkflowTask>();
    public ICollection<WorkflowActionHistory> ActionHistories { get; set; } = new List<WorkflowActionHistory>();
}
