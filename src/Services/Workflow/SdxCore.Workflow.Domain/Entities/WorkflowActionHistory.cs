using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowActionHistory : BaseEntity<int>
{
    public int WorkflowInstanceId { get; set; }
    public int? WorkflowTaskId { get; set; }
    public short? WorkflowStepId { get; set; }
    public string WorkflowActionType { get; set; } = null!;  // FK → WORKFLOW_ACTION_TYPE
    // Computed: WorkflowActionTypeGroup = 'WORKFLOW_ACTION_TYPE'
    public string? Remarks { get; set; }
    public string? FromWorkflowStatus { get; set; }
    // Computed: FromWorkflowStatusGroup = 'WORKFLOW_STATUS'
    public string? ToWorkflowStatus { get; set; }
    // Computed: ToWorkflowStatusGroup = 'WORKFLOW_STATUS'
    public bool IsActive { get; set; } = true;
    public int ActionBy { get; set; }
    public DateTime ActionAt { get; set; }

    // Navigation
    public WorkflowInstance Instance { get; set; } = null!;
    public WorkflowTask? Task { get; set; }
    public WorkflowStep? Step { get; set; }
}
