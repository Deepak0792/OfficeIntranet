using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

public class RotationShiftAssignment : BaseAuditEntity<Guid>
{
    public Guid RotationShiftId { get; set; }

    /// <summary>Cross-schema FK to time.ScopeType — ID only, no nav prop.</summary>
    public Guid ScopeTypeId { get; set; }

    /// <summary>Cross-schema reference ID — ID only, no nav prop.</summary>
    public Guid? ScopeReferenceId { get; set; }

    public int RotationOffsetDays { get; set; }
    public DateOnly RotationStartDate { get; set; }
    public DateOnly EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
    public bool IsActive { get; set; } = true;

    // Intra-schema navigation
    public RotationShift RotationShift { get; set; } = null!;
}
