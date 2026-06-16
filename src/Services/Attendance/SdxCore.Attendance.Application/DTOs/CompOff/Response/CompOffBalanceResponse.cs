namespace SdxCore.Attendance.Application.DTOs.CompOff.Response;

public record CompOffBalanceResponse(
    Guid Id,
    Guid EmployeeId,
    Guid CompOffTypeId,
    string CompOffTypeName,
    DateOnly EarnedDate,
    DateOnly? ExpiryDate,
    decimal TotalDays,
    decimal AvailedDays,
    decimal RemainingDays,
    Guid? WorkflowInstanceId);
