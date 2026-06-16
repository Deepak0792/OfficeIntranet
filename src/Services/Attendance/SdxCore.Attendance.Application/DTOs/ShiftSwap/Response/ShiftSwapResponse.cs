namespace SdxCore.Attendance.Application.DTOs.ShiftSwap.Response;

public record ShiftSwapResponse(
    Guid Id,
    Guid RequesterEmployeeId,
    Guid TargetEmployeeId,
    Guid RequesterRosterId,
    Guid TargetRosterId,
    string ShiftSwapStatus,
    Guid? WorkflowInstanceId,
    DateTime RequestedAt,
    Guid? ApprovedBy,
    DateTime? ApprovedAt,
    string? Remarks);
