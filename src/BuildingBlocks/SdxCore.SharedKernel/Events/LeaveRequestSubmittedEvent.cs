namespace SdxCore.SharedKernel.Events;

/// <summary>
/// Published by Attendance when an employee submits a leave request.
/// Consumed by Workflow to initiate the approval workflow.
/// </summary>
public record LeaveRequestSubmittedEvent(
    Guid LeaveRequestId,
    Guid EmployeeId,
    string LeaveTypeCode,     // e.g. "ANNUAL", "SICK", "EMERGENCY"
    string ModuleCode,        // always "LEAVE_REQUEST"
    DateOnly FromDate,
    DateOnly ToDate,
    string? Remarks,
    DateTime CreatedAt);