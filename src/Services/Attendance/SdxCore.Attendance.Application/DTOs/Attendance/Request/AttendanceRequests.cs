namespace SdxCore.Attendance.Application.DTOs.Attendance.Request;

public record CheckInRequest(Guid EmployeeId, DateTime CheckInTime, string? DeviceId = null);

public record CheckOutRequest(Guid EmployeeId, DateTime CheckOutTime);

public record CreateRegularizationRequest(
    Guid EmployeeId,
    DateOnly AttendanceDate,
    DateTime? RequestedCheckIn,
    DateTime? RequestedCheckOut,
    string? Reason);
