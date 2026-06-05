namespace SdxCore.Workflow.Application.Services;

public record WorkflowEvent(
    string EventType,
    int WorkflowInstanceId,
    string ModuleCode,
    int ReferenceTransactionId,
    string NewStatus,
    int ActionBy = 0);
