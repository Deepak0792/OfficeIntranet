using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

/// <summary>
/// One row per employee per date. IsLocked=true protects from overwrite by GenerateRosterAsync.
/// UNIQUE: (EmployeeId, RosterDate)
/// </summary>
public class EmployeeShiftRoster : BaseAuditEntity<Guid>
{
    /// <summary>Cross-schema FK to employee.Employee — ID only, no nav prop.</summary>
    public Guid EmployeeId { get; set; }

    public DateOnly RosterDate { get; set; }

    /// <summary>Nullable — null when IsOffDay or IsHoliday.</summary>
    public Guid? ShiftId { get; set; }

    public bool IsOffDay { get; set; }
    public bool IsHoliday { get; set; }
    public bool IsWeekend { get; set; }
    public Guid? RosterTimeZoneId { get; set; }
    public DateTime? StartTimeLocal { get; set; }
    public DateTime? EndTimeLocal { get; set; }
    public DateTime? PlannedStartTime { get; set; }
    public DateTime? PlannedEndTime { get; set; }
    public DateTime? ActualStartTime { get; set; }
    public DateTime? ActualEndTime { get; set; }
    public string? Remarks { get; set; }
    public bool IsLocked { get; set; }
    public bool IsActive { get; set; } = true;

    // Intra-schema navigation
    public Shift? Shift { get; set; }
}
