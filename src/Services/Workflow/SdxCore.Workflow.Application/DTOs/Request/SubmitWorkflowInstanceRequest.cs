namespace SdxCore.Workflow.Application.DTOs.Request;

public record SubmitWorkflowInstanceRequest(
    string ModuleCode,
    string WorkflowCode,
    int    ReferenceTransactionId,
    int    InitiatedByEmployeeId);
