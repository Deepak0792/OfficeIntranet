using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeRelationship : BaseAuditEntity<Guid>, IPublishableEntity
{
    /// <summary>The employee who is the parent in this relationship (e.g. the manager).</summary>
    public Guid ParentEmployeeId { get; set; }

    /// <summary>The employee who is the child in this relationship (e.g. the reportee).</summary>
    public Guid ChildEmployeeId { get; set; }

    /// <summary>Lookup-backed relationship type (e.g. DIRECT_MANAGER). FK to shared.StatusLookup.</summary>
    public string RelationshipType { get; set; } = null!;

    /// <summary>
    /// Cross-schema FK to time.Department — stored as ID only.
    /// Represents the department context for this relationship.
    /// </summary>
    public Guid? DepartmentId { get; set; }

    public bool IsPrimaryRelationship { get; set; }
    public DateOnly? EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────

    /// <summary>The parent employee (e.g. manager). Both employees are in employee schema.</summary>
    public Employee ParentEmployee { get; set; } = null!;

    /// <summary>The child employee (e.g. reportee). Both employees are in employee schema.</summary>
    public Employee ChildEmployee { get; set; } = null!;
}
