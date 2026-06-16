using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

public class WorkWeekPolicyAssignment : BaseAuditEntity<Guid>
{
    public Guid WorkWeekPolicyId { get; set; }

    /// <summary>Cross-schema FK to time.ScopeType — ID only, no nav prop.</summary>
    public Guid ScopeTypeId { get; set; }

    /// <summary>Cross-schema reference ID — ID only, no nav prop.</summary>
    public Guid? ScopeReferenceId { get; set; }

    public DateOnly EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
    public short PriorityOrder { get; set; }
    public bool IsActive { get; set; } = true;

    // Intra-schema navigation
    public WorkWeekPolicy WorkWeekPolicy { get; set; } = null!;
}
