using SdxCore.Workflow.Application.DTOs.ActionHistory.Response;
using SdxCore.Workflow.Application.DTOs.Task.Response;

namespace SdxCore.Workflow.Application.DTOs.Instance.Response;

public record WorkflowInstanceDetailResponse(
    Guid Id,
    string WorkflowCode,
    string WorkflowName,
    string ModuleCode,
    Guid ReferenceTransactionId,
    Guid? CurrentWorkflowStepId,
    string? CurrentStepName,
    string WorkflowStatus,
    Guid? CreatedBy,
    DateTime CreatedAt,
    DateTime? CompletedAt,
    IEnumerable<WorkflowTaskResponse> Tasks,
    IEnumerable<WorkflowActionHistoryResponse> History);
