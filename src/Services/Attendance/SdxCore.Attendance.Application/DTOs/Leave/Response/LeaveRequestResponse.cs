namespace SdxCore.Attendance.Application.DTOs.Leave.Response;

public record LeaveRequestResponse(
    Guid Id,
    Guid EmployeeId,
    Guid LeaveTypeId,
    string LeaveTypeName,
    string LeaveStatus,
    DateOnly FromDate,
    DateOnly ToDate,
    decimal TotalDays,
    bool IsHalfDay,
    string? HalfDaySession,
    string? Reason,
    Guid? WorkflowInstanceId,
    string? Remarks,
    Guid? ApprovedBy,
    DateTime? ApprovedAt,
    DateTime CreatedAt);
