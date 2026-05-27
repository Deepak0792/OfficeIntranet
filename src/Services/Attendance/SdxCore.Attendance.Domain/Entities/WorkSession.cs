using System;

namespace SdxCore.Attendance.Domain.Entities;

public class WorkSession : BaseEntity
{
    public long Id { get; set; }
    public int EmployeeId { get; set; }
    public long? EmployeeShiftId { get; set; }
    public DateTime SessionDate { get; set; }
    public DateTime CheckInTime { get; set; }
    public DateTime? CheckOutTime { get; set; }
    public int? WorkedMinutes { get; set; }
}
