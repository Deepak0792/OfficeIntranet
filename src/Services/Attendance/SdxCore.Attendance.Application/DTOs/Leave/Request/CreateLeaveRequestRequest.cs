namespace SdxCore.Attendance.Application.DTOs.Leave.Request;

public record CreateLeaveRequestRequest(
    Guid EmployeeId,
    Guid LeaveTypeId,
    DateOnly FromDate,
    DateOnly ToDate,
    bool IsHalfDay = false,
    string? HalfDaySession = null,
    string? Reason = null);
