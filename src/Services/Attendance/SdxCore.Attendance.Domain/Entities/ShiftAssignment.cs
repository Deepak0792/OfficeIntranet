using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

public class ShiftAssignment : BaseAuditEntity<Guid>
{
    /// <summary>FK to Shift within attendance schema.</summary>
    public Guid ShiftId { get; set; }

    /// <summary>Cross-schema FK to time.ScopeType — ID only, no nav prop.</summary>
    public Guid ScopeTypeId { get; set; }

    /// <summary>Cross-schema reference ID (employee, team, dept, office, etc.) — ID only.</summary>
    public Guid? ScopeReferenceId { get; set; }

    public DateOnly EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
    public short PriorityOrder { get; set; }
    public bool IsPrimaryShift { get; set; } = true;
    public bool IsActive { get; set; } = true;

    // Intra-schema navigation
    public Shift Shift { get; set; } = null!;
}
