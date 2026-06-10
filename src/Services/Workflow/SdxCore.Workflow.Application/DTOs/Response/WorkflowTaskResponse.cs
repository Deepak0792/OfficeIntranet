namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowTaskResponse(
    Guid Id,
    Guid WorkflowInstanceId,
    Guid WorkflowStepId,
    string StepName,
    short StepNo,
    Guid WorkflowStepApproverId,
    Guid AssignedToEmployeeId,
    string AssignedToEmployeeName,
    Guid? DelegatedFromEmployeeId,
    string? DelegatedFromEmployeeName,
    string TaskStatus,
    string? Remarks,
    Guid? ParentWorkflowTaskId,
    DateTime AssignedAt,
    DateTime? DueAt,
    DateTime? ActionAt,
    // Context from parent instance
    string ModuleCode,
    Guid ReferenceTransactionId,
    string WorkflowStatus);
