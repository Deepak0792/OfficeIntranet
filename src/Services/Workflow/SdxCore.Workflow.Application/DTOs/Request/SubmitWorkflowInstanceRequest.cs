namespace SdxCore.Workflow.Application.DTOs.Request;

public record SubmitWorkflowInstanceRequest(
    string WorkflowModuleCode,
    int    ReferenceTransactionId,
    int    InitiatedByEmployeeId);
