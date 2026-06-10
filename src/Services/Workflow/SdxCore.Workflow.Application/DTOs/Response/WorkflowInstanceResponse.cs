namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowInstanceResponse(
    Guid Id,
    Guid WorkflowDefinitionId,
    string WorkflowCode,
    string WorkflowName,
    Guid WorkflowModuleId,
    string ModuleCode,
    Guid ReferenceTransactionId,
    Guid? CurrentWorkflowStepId,
    string? CurrentStepName,
    short? CurrentStepNo,
    string WorkflowStatus,
    Guid? CreatedBy,
    DateTime CreatedAt,
    DateTime? CompletedAt);
