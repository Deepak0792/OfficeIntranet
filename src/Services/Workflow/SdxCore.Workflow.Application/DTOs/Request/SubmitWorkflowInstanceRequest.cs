namespace SdxCore.Workflow.Application.DTOs.Request;

public record SubmitWorkflowInstanceRequest(
    string ModuleCode,
    string WorkflowCode,
    Guid ReferenceTransactionId,
    Guid InitiatedByEmployeeId);
