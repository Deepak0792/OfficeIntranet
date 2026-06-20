namespace SdxCore.Attendance.Application.DTOs;

public sealed class LeaveValidationResult
{
    public Guid LeaveTypeId { get; init; }

    public string LeaveTypeCode { get; init; } = string.Empty;

    public string LeaveTypeName { get; init; } = string.Empty;

    public decimal TotalLeaveDays { get; init; }

    public bool IsCompOff { get; init; }

    public bool IsLwp { get; init; }
}