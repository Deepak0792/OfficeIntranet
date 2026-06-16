namespace SdxCore.Attendance.Application.DTOs.CompOff.Request;

public record EarnCompOffRequest(
    Guid EmployeeId,
    Guid CompOffTypeId,
    DateOnly EarnedDate,
    decimal TotalDays,
    Guid? AttendanceRecordId = null);

public record RedeemCompOffRequest(
    Guid EmployeeId,
    Guid CompOffBalanceId,
    decimal RequestedDays);
