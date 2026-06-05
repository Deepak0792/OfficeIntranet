namespace SdxCore.Workflow.Application.DTOs.Response;

public record WorkflowTaskResponse(
    int      Id,
    int      WorkflowInstanceId,
    short    WorkflowStepId,
    string   StepName,
    short    StepNo,
    short    WorkflowStepApproverId,
    int      AssignedToEmployeeId,
    string   AssignedToEmployeeName,
    int?     DelegatedFromEmployeeId,
    string?  DelegatedFromEmployeeName,
    string   TaskStatus,
    string?  Remarks,
    int?     ParentWorkflowTaskId,
    DateTime AssignedAt,
    DateTime? DueAt,
    DateTime? ActionAt,
    // Context from parent instance
    string   ModuleCode,
    int      ReferenceTransactionId,
    string   WorkflowStatus);
