namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowInstanceResponse(
    int Id,
    short WorkflowDefinitionId,
    string WorkflowCode,
    string WorkflowName,
    short WorkflowModuleId,
    string ModuleCode,
    int ReferenceTransactionId,
    short? CurrentWorkflowStepId,
    string? CurrentStepName,
    short? CurrentStepNo,
    string WorkflowStatus,
    int? CreatedBy,
    DateTime CreatedAt,
    DateTime? CompletedAt);
