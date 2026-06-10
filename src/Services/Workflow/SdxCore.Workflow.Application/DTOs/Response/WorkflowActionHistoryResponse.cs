namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowActionHistoryResponse(
    Guid Id,
    Guid WorkflowInstanceId,
    Guid? WorkflowTaskId,
    Guid? WorkflowStepId,
    string? StepName,
    string WorkflowActionType,
    string? Remarks,
    string? FromWorkflowStatus,
    string? ToWorkflowStatus,
    Guid ActionBy,
    string ActionByName,
    DateTime ActionAt);
