namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowActionHistoryResponse(
    int      Id,
    int      WorkflowInstanceId,
    int?     WorkflowTaskId,
    short?   WorkflowStepId,
    string?  StepName,
    string   WorkflowActionType,
    string?  Remarks,
    string?  FromWorkflowStatus,
    string?  ToWorkflowStatus,
    int      ActionBy,
    string   ActionByName,
    DateTime ActionAt);
