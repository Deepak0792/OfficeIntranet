namespace SdxCore.Attendance.Application.DTOs.Leave.Response;

public record LeaveBalanceResponse(
    Guid LeaveTypeId,
    string LeaveTypeName,
    short BalanceYear,
    decimal OpeningBalance,
    decimal Allocated,
    decimal Availed,
    decimal CarryForward,
    decimal Encashed,
    decimal ClosingBalance);
