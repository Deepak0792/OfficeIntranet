using System;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowActionHistory : BaseEntity
{
    public int Id { get; set; }
    public int WorkflowInstanceId { get; set; }
    public int? WorkflowTaskId { get; set; }
    public short? WorkflowStepId { get; set; }
    public string WorkflowActionType { get; set; } = string.Empty;
    public string? Remarks { get; set; }
    public string? FromWorkflowStatus { get; set; }
    public string? ToWorkflowStatus { get; set; }
    public int ActionBy { get; set; }
    public DateTime ActionAt { get; set; } = DateTime.UtcNow;

    public WorkflowInstance? Instance { get; set; }
    public WorkflowTask? Task { get; set; }
    public WorkflowStep? Step { get; set; }
}
