using SdxCore.SharedKernel.Entities;

namespace SdxCore.Attendance.Domain.Entities;

/// <summary>
/// Defines how rosters are generated (auto vs manual, days-in-advance, lock behaviour).
/// UNIQUE: PolicyCode
/// </summary>
public class RosterGenerationPolicy : BaseAuditEntity<Guid>
{
    public string PolicyCode { get; set; } = string.Empty;
    public string PolicyName { get; set; } = string.Empty;

    /// <summary>e.g. "AUTO", "MANUAL", "ROTATION"</summary>
    public string GenerationType { get; set; } = string.Empty;

    /// <summary>
    /// Persisted computed column — CAST('ROSTER_GENERATION_TYPE' AS NVARCHAR(50)).
    /// Do not set from application code.
    /// </summary>
    public string GenerationTypeGroup { get; set; } = string.Empty;

    /// <summary>How many days before the roster period to auto-generate.</summary>
    public short GenerateDaysBefore { get; set; } = 7;
    public bool AutoGenerate { get; set; } = true;
    public bool LockAfterGeneration { get; set; }
    public bool IsDefault { get; set; }
    public bool IsActive { get; set; } = true;

    // Intra-schema reverse navigation
    public ICollection<RosterGenerationPolicyAssignment> Assignments { get; set; } = [];
}
