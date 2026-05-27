using System;

namespace SdxCore.Attendance.Domain.Entities;

public class EmployeeShiftRoster : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public DateTime RosterDate { get; set; }
    public short? ShiftId { get; set; }
    public bool IsOffDay { get; set; } = false;
    public bool IsHoliday { get; set; } = false;
    public DateTime? PlannedStartTime { get; set; }
    public DateTime? PlannedEndTime { get; set; }
    public DateTime? ActualStartTime { get; set; }
    public DateTime? ActualEndTime { get; set; }
    public string? Remarks { get; set; }
    public bool IsLocked { get; set; } = false;
}
