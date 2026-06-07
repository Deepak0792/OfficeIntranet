namespace SdxCore.SharedKernel.Events;

public record WorkflowChangedEvent(
    string EventType,
    int WorkflowInstanceId,
    string ModuleCode,
    int ReferenceTransactionId,
    string NewStatus,
    int ActionBy = 0);