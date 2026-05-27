using System;
using System.Collections.Generic;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowTask : BaseEntity
{
    public int Id { get; set; }
    public int WorkflowInstanceId { get; set; }
    public short WorkflowStepId { get; set; }
    public short WorkflowStepApproverId { get; set; }
    public int AssignedToEmployeeId { get; set; }
    public int? DelegatedFromEmployeeId { get; set; }
    public string TaskStatus { get; set; } = string.Empty;
    public string? Remarks { get; set; }
    public int? ParentWorkflowTaskId { get; set; }
    public DateTime AssignedAt { get; set; } = DateTime.UtcNow;
    public DateTime? DueAt { get; set; }
    public DateTime? ActionAt { get; set; }
    public int? ActionBy { get; set; }

    public WorkflowInstance? Instance { get; set; }
    public WorkflowStep? Step { get; set; }
    public WorkflowStepApprover? StepApprover { get; set; }
    public WorkflowTask? ParentTask { get; set; }
    public ICollection<WorkflowTask> ChildTasks { get; set; } = new List<WorkflowTask>();
    public ICollection<WorkflowActionHistory> ActionHistories { get; set; } = new List<WorkflowActionHistory>();
}
