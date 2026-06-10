using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowInstance : BaseAuditEntity<Guid>
{
    public Guid WorkflowDefinitionId { get; set; }
    public Guid WorkflowModuleId { get; set; }
    public Guid ReferenceTransactionId { get; set; }
    public Guid? CurrentWorkflowStepId { get; set; }  
    public string WorkflowStatus { get; set; } = null!; 
    public DateTime? CompletedAt { get; set; }
    public Guid? CompletedBy { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation
    public WorkflowDefinition Definition { get; set; } = null!;
    public WorkflowModule Module { get; set; } = null!;
    public WorkflowStep? CurrentStep { get; set; }
    public ICollection<WorkflowTask> Tasks { get; set; } = [];
    public ICollection<WorkflowActionHistory> History { get; set; } = [];
}
