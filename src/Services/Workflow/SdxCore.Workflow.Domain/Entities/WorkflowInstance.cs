using SdxCore.SharedKernel.Entities;

namespace SdxCore.Workflow.Domain.Entities;

public class WorkflowInstance : BaseAuditEntity<int>
{
    public short WorkflowDefinitionId { get; set; }
    public short WorkflowModuleId { get; set; }
    public int ReferenceTransactionId { get; set; }
    public short? CurrentWorkflowStepId { get; set; }  
    public string WorkflowStatus { get; set; } = null!; 
    public DateTime? CompletedAt { get; set; }
    public int? CompletedBy { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation
    public WorkflowDefinition Definition { get; set; } = null!;
    public WorkflowModule Module { get; set; } = null!;
    public WorkflowStep? CurrentStep { get; set; }
    public ICollection<WorkflowTask> Tasks { get; set; } = [];
    public ICollection<WorkflowActionHistory> History { get; set; } = [];
}
