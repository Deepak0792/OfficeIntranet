namespace SdxCore.SharedKernel.Events;

/// <summary>
/// Published by Workflow when an instance status changes (Approved/Rejected/etc).
/// Consumed by Attendance to update LeaveRequest.LeaveStatus.
/// </summary>
public record WorkflowInstanceStatusChangedEvent(
    int WorkflowInstanceId,
    string ModuleCode,              // "LEAVE_REQUEST"
    int ReferenceTransactionId,  // LeaveRequestId
    string NewStatus,               // "APPROVED", "REJECTED", "WITHDRAWN", etc.
    string ActionType,
    int ActionBy,
    string? Remarks,
    DateTime OccurredOnUtc);