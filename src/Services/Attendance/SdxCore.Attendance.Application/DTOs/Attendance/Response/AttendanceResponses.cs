namespace SdxCore.Attendance.Application.DTOs.Attendance.Response;

public record AttendanceRecordResponse(
    Guid Id,
    Guid EmployeeId,
    DateOnly AttendanceDate,
    string? StatusCode,
    string? StatusName,
    DateTime? CheckInTime,
    DateTime? CheckOutTime,
    short? WorkedMinutes,
    short? LateByMinutes,
    short OvertimeMinutes,
    bool IsRegularized,
    bool IsManualEntry,
    bool IsAutoProcessed,
    DateTime? LockedAt);

public record RegularizationResponse(
    Guid Id,
    Guid EmployeeId,
    DateOnly AttendanceDate,
    DateTime? RequestedCheckIn,
    DateTime? RequestedCheckOut,
    string? Reason,
    string RegularizationStatus,
    Guid? WorkflowInstanceId,
    Guid? ApprovedBy,
    DateTime? ApprovedAt,
    string? Remarks);
