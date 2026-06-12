namespace SdxCore.Workflow.Application.DTOs.Instance.Request;

public record SubmitWorkflowInstanceRequest(
    string ModuleCode,
    string WorkflowCode,
    Guid ReferenceTransactionId,
    Guid InitiatedByEmployeeId);
