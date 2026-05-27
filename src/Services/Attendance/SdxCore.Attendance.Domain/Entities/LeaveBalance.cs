namespace SdxCore.Attendance.Domain.Entities;

public class LeaveBalance : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short LeaveTypeId { get; set; }
    public short BalanceYear { get; set; }
    public decimal OpeningBalance { get; set; } = 0;
    public decimal Allocated { get; set; } = 0;
    public decimal Availed { get; set; } = 0;
    public decimal Encashed { get; set; } = 0;
    public decimal CarryForward { get; set; } = 0;
}
