using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowActionHistory : BaseAuditEntity<int>
{
    public int WorkflowInstanceId { get; set; }
    public int? WorkflowTaskId { get; set; }
    public short? WorkflowStepId { get; set; }
    public string WorkflowActionType { get; set; } = null!; 
    public string? Remarks { get; set; }
    public string? FromWorkflowStatus { get; set; }
    public string? ToWorkflowStatus { get; set; }
    public bool IsActive { get; set; } = true;
    public int ActionBy { get; set; }
    public DateTime ActionAt { get; set; }

    // Navigation
    public WorkflowInstance Instance { get; set; } = null!;
    public WorkflowTask? Task { get; set; }
    public WorkflowStep? Step { get; set; }
}
