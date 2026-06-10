using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowTask : BaseAuditEntity<Guid>
{
    public Guid WorkflowInstanceId { get; set; }
    public Guid WorkflowStepId { get; set; }
    public Guid WorkflowStepApproverId { get; set; }
    public Guid AssignedToEmployeeId { get; set; }
    public Guid? DelegatedFromEmployeeId { get; set; }
    public string TaskStatus { get; set; } = null!;
    public string? Remarks { get; set; }
    public Guid? ParentWorkflowTaskId { get; set; }
    public DateTime AssignedAt { get; set; } = DateTime.UtcNow;
    public DateTime? DueAt { get; set; }
    public DateTime? ActionAt { get; set; }
    public Guid ActionBy { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation
    public WorkflowInstance Instance { get; set; } = null!;
    public WorkflowStep Step { get; set; } = null!;
    public WorkflowStepApprover StepApprover { get; set; } = null!;
    public WorkflowTask? ParentTask { get; set; }
}