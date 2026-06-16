using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

/// <summary>
/// Processed daily attendance record.
/// UNIQUE: (EmployeeId, AttendanceDate)
/// </summary>
public class AttendanceRecord : BaseAuditEntity<Guid>
{
    /// <summary>Cross-schema FK to employee.Employee — ID only, no nav prop.</summary>
    public Guid EmployeeId { get; set; }

    public Guid? EmployeeShiftRosterId { get; set; }
    public Guid? WorkSessionId { get; set; }
    public DateOnly AttendanceDate { get; set; }
    public Guid? ShiftId { get; set; }
    public Guid? AttendanceStatusId { get; set; }
    public DateTime? CheckInTime { get; set; }
    public DateTime? CheckOutTime { get; set; }
    public short? LateByMinutes { get; set; }
    public short? EarlyExitMinutes { get; set; }
    public short? WorkedMinutes { get; set; }
    public short BreakMinutes { get; set; }
    public short OvertimeMinutes { get; set; }
    public bool IsNightShift { get; set; }
    public bool IsCrossDayAttendance { get; set; }
    public bool IsWeeklyOff { get; set; }
    public bool IsHoliday { get; set; }
    public bool IsOnLeave { get; set; }
    public bool IsManualEntry { get; set; }
    public bool IsAutoProcessed { get; set; }
    public bool IsAttendanceLocked { get; set; }
    public string? Remarks { get; set; }

    /// <summary>Cross-schema FK to employee.Employee — ID only, no nav prop.</summary>
    public Guid? ApprovedBy { get; set; }

    public DateTime? ApprovedAt { get; set; }
    public bool IsActive { get; set; } = true;

    // Intra-schema navigations
    public EmployeeShiftRoster? EmployeeShiftRoster { get; set; }
    public WorkSession? WorkSession { get; set; }
    public Shift? Shift { get; set; }
    public AttendanceStatus? AttendanceStatus { get; set; }
}
