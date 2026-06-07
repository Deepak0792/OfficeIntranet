namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowInstanceDetailResponse(
    int Id,
    string WorkflowCode,
    string WorkflowName,
    string ModuleCode,
    int ReferenceTransactionId,
    short? CurrentWorkflowStepId,
    string? CurrentStepName,
    string WorkflowStatus,
    int? CreatedBy,
    DateTime CreatedAt,
    DateTime? CompletedAt,
    IEnumerable<WorkflowTaskResponse> Tasks,
    IEnumerable<WorkflowActionHistoryResponse> History);
