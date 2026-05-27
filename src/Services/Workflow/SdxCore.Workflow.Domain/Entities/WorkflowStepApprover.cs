using System.Collections.Generic;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowStepApprover : BaseEntity
{
    public short Id { get; set; }
    public short WorkflowStepId { get; set; }
    public string WorkflowApproverType { get; set; } = string.Empty;
    public short? ScopeTypeId { get; set; }
    public short? ScopeReferenceId { get; set; }
    public short PriorityOrder { get; set; } = 1;
    public bool IsMandatory { get; set; } = true;

    public WorkflowStep? Step { get; set; }
    public ICollection<WorkflowStepApproverDesignation> Designations { get; set; } = new List<WorkflowStepApproverDesignation>();
    public ICollection<WorkflowTask> Tasks { get; set; } = new List<WorkflowTask>();
}
