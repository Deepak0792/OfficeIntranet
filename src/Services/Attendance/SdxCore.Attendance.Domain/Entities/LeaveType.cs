namespace SdxCore.Attendance.Domain.Entities;

public class LeaveType : BaseEntity
{
    public short Id { get; set; }
    public string LeaveCode { get; set; } = string.Empty;
    public string LeaveName { get; set; } = string.Empty;
    public bool IsPaid { get; set; } = true;
    public decimal? MaxDaysPerYear { get; set; }
    public bool AllowCarryForward { get; set; } = false;
    public bool RequiresApproval { get; set; } = true;
    public bool AllowHalfDay { get; set; } = true;
}
