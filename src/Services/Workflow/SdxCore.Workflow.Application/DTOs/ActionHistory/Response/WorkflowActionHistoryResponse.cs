namespace SdxCore.Workflow.Application.DTOs.ActionHistory.Response;

public sealed class WorkflowActionHistoryResponse
{
    public Guid Id { get; set; }
    public Guid WorkflowInstanceId { get; set; }
    public Guid? WorkflowTaskId { get; set; }
    public Guid? WorkflowStepId { get; set; }
    public string? StepName { get; set; }
    public string WorkflowActionType { get; set; } = default!;
    public string? Remarks { get; set; }
    public string? FromWorkflowStatus { get; set; }
    public string? ToWorkflowStatus { get; set; }
    public Guid ActionBy { get; set; }
    public string ActionByName { get; set; } = default!;
    public DateTime ActionAt { get; set; }
}
