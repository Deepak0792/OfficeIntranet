using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowTask : BaseAuditEntity<int>
{
    public int WorkflowInstanceId { get; set; }
    public short WorkflowStepId { get; set; }
    public short WorkflowStepApproverId { get; set; }
    public int AssignedToEmployeeId { get; set; }
    public int? DelegatedFromEmployeeId { get; set; }
    public string TaskStatus { get; set; } = null!;
    public string? Remarks { get; set; }
    public int? ParentWorkflowTaskId { get; set; }
    public DateTime AssignedAt { get; set; } = DateTime.UtcNow;
    public DateTime? DueAt { get; set; }
    public DateTime? ActionAt { get; set; }
    public int ActionBy { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation
    public WorkflowInstance Instance { get; set; } = null!;
    public WorkflowStep Step { get; set; } = null!;
    public WorkflowStepApprover StepApprover { get; set; } = null!;
    public WorkflowTask? ParentTask { get; set; }
}