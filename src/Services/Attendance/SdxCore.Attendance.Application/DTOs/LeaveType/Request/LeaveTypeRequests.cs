namespace SdxCore.Attendance.Application.DTOs.LeaveType.Request;

public record CreateLeaveTypeRequest(
    string LeaveCode,
    string LeaveName,
    bool IsPaid,
    decimal? MaxDaysPerYear,
    bool AllowCarryForward,
    bool RequiresApproval,
    bool AllowHalfDay,
    string? WorkflowCode);

public record UpdateLeaveTypeRequest(
    string? LeaveName,
    bool? IsPaid,
    decimal? MaxDaysPerYear,
    bool? AllowCarryForward,
    bool? RequiresApproval,
    bool? AllowHalfDay,
    string? WorkflowCode);
