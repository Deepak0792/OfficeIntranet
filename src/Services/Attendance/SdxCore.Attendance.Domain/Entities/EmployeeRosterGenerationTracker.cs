using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

/// <summary>
/// Tracks roster generation per employee per period.
/// UNIQUE: (EmployeeId, RosterYear, RosterMonth, GenerationType)
/// GenerationTypeGroup is a computed/persisted column — never written by EF.
/// </summary>
public class EmployeeRosterGenerationTracker : BaseAuditEntity<Guid>
{
    /// <summary>Cross-schema FK to employee.Employee — ID only, no nav prop.</summary>
    public Guid EmployeeId { get; set; }

    public short RosterYear { get; set; }
    public byte RosterMonth { get; set; }

    /// <summary>FK to shared.StatusLookup group ROSTER_GENERATION_TYPE. Values: MONTHLY, WEEKLY, ADHOC.</summary>
    public required string GenerationType { get; set; }

    /// <summary>Computed persisted column — DO NOT ASSIGN. FK group for StatusLookup.</summary>
    public string GenerationTypeGroup { get; set; } = string.Empty;

    public DateOnly GeneratedFromDate { get; set; }
    public DateOnly GeneratedToDate { get; set; }
    public DateTime LastGeneratedAt { get; set; }
    public bool IsLocked { get; set; }
    public string? Remarks { get; set; }
    public bool IsActive { get; set; } = true;
}
