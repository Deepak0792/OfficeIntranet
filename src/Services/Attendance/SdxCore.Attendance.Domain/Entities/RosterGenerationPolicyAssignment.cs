using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

/// <summary>
/// Assigns a <see cref="RosterGenerationPolicy"/> to a scope (company, department, location, etc.).
/// UNIQUE: (ScopeTypeId, ScopeReferenceId, EffectiveFrom)
/// </summary>
public class RosterGenerationPolicyAssignment : BaseAuditEntity<Guid>
{
    public Guid RosterGenerationPolicyId { get; set; }

    /// <summary>Cross-schema FK to time.ScopeType — ID only, no nav prop.</summary>
    public Guid ScopeTypeId { get; set; }

    /// <summary>Nullable — null means policy applies to the entire scope type (e.g., all employees).</summary>
    public Guid? ScopeReferenceId { get; set; }

    public DateOnly EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }

    /// <summary>Lower number = higher priority when multiple assignments overlap.</summary>
    public short PriorityOrder { get; set; } = 1;

    public bool IsActive { get; set; } = true;

    // Intra-schema navigation
    public RosterGenerationPolicy? RosterGenerationPolicy { get; set; }
}
