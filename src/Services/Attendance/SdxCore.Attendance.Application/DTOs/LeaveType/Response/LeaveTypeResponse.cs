namespace SdxCore.Attendance.Application.DTOs.LeaveType.Response;

public record LeaveTypeResponse(
    Guid Id,
    string LeaveCode,
    string LeaveName,
    bool IsPaid,
    decimal? MaxDaysPerYear,
    bool AllowCarryForward,
    bool RequiresApproval,
    bool AllowHalfDay,
    string? WorkflowCode,
    bool IsActive);
