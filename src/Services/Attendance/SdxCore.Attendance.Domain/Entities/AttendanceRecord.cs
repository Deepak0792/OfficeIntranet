using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

/// <summary>
/// Processed daily attendance record.
/// UNIQUE: (EmployeeId, AttendanceDate)
/// </summary>
public class AttendanceRecord : BaseAuditEntity<Guid>
{
    /// <summary>
    /// Cross-schema FK to employee.Employee.
    /// </summary>
    public Guid EmployeeId { get; set; }

    public Guid? EmployeeShiftRosterId { get; set; }

    public DateOnly AttendanceDate { get; set; }

    public Guid? ShiftId { get; set; }

    public Guid? AttendanceStatusId { get; set; }

    public Guid? LeaveRequestId { get; set; }

    public Guid? RegularizationRequestId { get; set; }

    public short SessionCount { get; set; }

    public DateTime? CheckInTime { get; set; }

    public DateTime? CheckOutTime { get; set; }

    public short? WorkedMinutes { get; set; }

    public short BreakMinutes { get; set; }

    public short MinimumWorkingMinutes { get; set; }

    public short? LateByMinutes { get; set; }

    public short? EarlyExitMinutes { get; set; }

    public short OvertimeMinutes { get; set; }

    public bool IsRegularized { get; set; }

    public bool IsManualEntry { get; set; }

    public bool IsAutoProcessed { get; set; }

    /// <summary>
    /// References shared.StatusLookup(StatusCode)
    /// where StatusGroup = 'ATTENDANCE_STATE'.
    /// </summary>
    public string? AttendanceState { get; set; }

    public string? Remarks { get; set; }

    /// <summary>
    /// Cross-schema FK to employee.Employee.
    /// </summary>
    public Guid? ApprovedBy { get; set; }

    public DateTime? ApprovedAt { get; set; }

    public DateTime FinalizeDueAt { get; set; }

    public DateTime? FinalizedAt { get; set; }

    public DateTime? LockedAt { get; set; }

    public bool IsActive { get; set; } = true;

    // Navigation properties
    public EmployeeShiftRoster? EmployeeShiftRoster { get; set; }

    public Shift? Shift { get; set; }

    public AttendanceStatus? AttendanceStatus { get; set; }
}