namespace SdxCore.SharedKernel.Events;

/// <summary>
/// Published by Workflow when an instance status changes (Approved/Rejected/etc).
/// Consumed by Attendance to update LeaveRequest.LeaveStatus.
/// </summary>
public record WorkflowInstanceStatusChangedEvent(
    Guid WorkflowInstanceId,
    string ModuleCode,              // "LEAVE_REQUEST"
    Guid ReferenceTransactionId,  // LeaveRequestId
    string NewStatus,               // "APPROVED", "REJECTED", "WITHDRAWN", etc.
    string ActionType,
    Guid ActionBy,
    string? Remarks,
    DateTime OccurredOnUtc);