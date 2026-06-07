namespace SdxCore.SharedKernel.Events;

/// <summary>
/// Published by Attendance when an employee submits a leave request.
/// Consumed by Workflow to initiate the approval workflow.
/// </summary>
public record LeaveRequestSubmittedEvent(
    int LeaveRequestId,
    int EmployeeId,
    string LeaveTypeCode,     // e.g. "ANNUAL", "SICK", "EMERGENCY"
    string WorkflowCode,      // e.g. "STANDARD_LEAVE_V1", "EMERGENCY_LEAVE_V1"
    string ModuleCode,        // always "LEAVE_REQUEST"
    DateOnly StartDate,
    DateOnly EndDate,
    string? Remarks,
    DateTime OccurredOnUtc);