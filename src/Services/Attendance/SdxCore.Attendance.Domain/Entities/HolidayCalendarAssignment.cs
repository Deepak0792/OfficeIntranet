using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

/// <summary>
/// Assigns a HolidayCalendar to a scope with merge strategy.
/// MergeStrategy: MERGE = union; REPLACE = override lower-scope calendars.
/// </summary>
public class HolidayCalendarAssignment : BaseAuditEntity<Guid>
{
    public Guid HolidayCalendarId { get; set; }

    /// <summary>Cross-schema FK to time.ScopeType — ID only, no nav prop.</summary>
    public Guid ScopeTypeId { get; set; }

    /// <summary>Cross-schema reference ID — ID only, no nav prop.</summary>
    public Guid? ScopeReferenceId { get; set; }

    public DateOnly? EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
    public short PriorityOrder { get; set; }
    public required string MergeStrategy { get; set; }
    public bool IsPrimary { get; set; }
    public bool IsActive { get; set; } = true;

    // Intra-schema navigation
    public HolidayCalendar HolidayCalendar { get; set; } = null!;
}
