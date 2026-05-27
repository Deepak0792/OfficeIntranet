using System;

namespace SdxCore.Attendance.Domain.Entities;

public class LeaveRequest : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short LeaveTypeId { get; set; }
    public string LeaveStatus { get; set; } = string.Empty;
    public DateTime FromDate { get; set; }
    public DateTime ToDate { get; set; }
    public decimal TotalDays { get; set; }
    public bool IsHalfDay { get; set; } = false;
    public string? HalfDaySession { get; set; }
    public string? Reason { get; set; }
    public int? WorkflowInstanceId { get; set; }
    public string? Remarks { get; set; }
    public int? ApprovedBy { get; set; }
    public DateTime? ApprovedAt { get; set; }
}
