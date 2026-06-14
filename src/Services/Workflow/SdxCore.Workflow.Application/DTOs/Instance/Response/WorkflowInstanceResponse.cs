namespace SdxCore.Workflow.Application.DTOs.Instance.Response;

public sealed class WorkflowInstanceResponse
{
    public Guid Id { get; set; }
    public Guid WorkflowDefinitionId { get; set; }
    public string WorkflowCode { get; set; } = default!;
    public string WorkflowName { get; set; } = default!;
    public Guid WorkflowModuleId { get; set; }
    public string ModuleCode { get; set; } = default!;
    public Guid ReferenceTransactionId { get; set; }
    public Guid? CurrentWorkflowStepId { get; set; }
    public string? CurrentStepName { get; set; }
    public short? CurrentStepNo { get; set; }
    public string WorkflowStatus { get; set; } = default!;
    public Guid? CreatedBy { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
}
