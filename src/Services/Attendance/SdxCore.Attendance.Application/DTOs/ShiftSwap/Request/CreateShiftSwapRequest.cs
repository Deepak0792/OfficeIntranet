namespace SdxCore.Attendance.Application.DTOs.ShiftSwap.Request;

public record CreateShiftSwapRequest(
    Guid RequesterEmployeeId,
    Guid TargetEmployeeId,
    Guid RequesterRosterId,
    Guid TargetRosterId);
