using SdxCore.Workflow.Application.DTOs.ActionHistory.Response;
using SdxCore.Workflow.Application.DTOs.Task.Response;

namespace SdxCore.Workflow.Application.DTOs.Instance.Response;

public sealed class WorkflowInstanceDetailResponse
{
    public Guid Id { get; set; }
    public string WorkflowCode { get; set; } = default!;
    public string WorkflowName { get; set; } = default!;
    public string ModuleCode { get; set; } = default!;
    public Guid ReferenceTransactionId { get; set; }
    public Guid? CurrentWorkflowStepId { get; set; }
    public string? CurrentStepName { get; set; }
    public string WorkflowStatus { get; set; } = default!;
    public Guid? CreatedBy { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
    public IEnumerable<WorkflowTaskResponse> Tasks { get; set; } = [];
    public IEnumerable<WorkflowActionHistoryResponse> History { get; set; } = [];
}
