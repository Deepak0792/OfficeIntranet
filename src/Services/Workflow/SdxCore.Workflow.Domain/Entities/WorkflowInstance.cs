using System;
using System.Collections.Generic;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowInstance : BaseEntity
{
    public int Id { get; set; }
    public short WorkflowDefinitionId { get; set; }
    public short WorkflowModuleId { get; set; }
    public int ReferenceTransactionId { get; set; }
    public short? CurrentWorkflowStepId { get; set; }
    public string WorkflowStatus { get; set; } = string.Empty;
    public DateTime? CompletedAt { get; set; }
    public int? CompletedBy { get; set; }

    public WorkflowDefinition? Definition { get; set; }
    public WorkflowModule? Module { get; set; }
    public WorkflowStep? CurrentStep { get; set; }
    public ICollection<WorkflowTask> Tasks { get; set; } = new List<WorkflowTask>();
    public ICollection<WorkflowActionHistory> ActionHistories { get; set; } = new List<WorkflowActionHistory>();
}
