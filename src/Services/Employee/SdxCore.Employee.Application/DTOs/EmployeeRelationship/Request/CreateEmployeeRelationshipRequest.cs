namespace SdxCore.Employee.Application.DTOs.EmployeeRelationship.Request;

public class CreateEmployeeRelationshipRequest
{
    /// <summary>The child employee in this relationship (e.g. the reportee being managed).</summary>
    public Guid ChildEmployeeId { get; set; }

    /// <summary>Lookup code from shared.StatusLookup under group RELATIONSHIP_TYPE (e.g. DIRECT_MANAGER).</summary>
    public string RelationshipType { get; set; } = null!;

    /// <summary>Optional department context for this relationship. Cross-schema FK to time.Department.</summary>
    public Guid? DepartmentId { get; set; }

    public bool IsPrimaryRelationship { get; set; }
    public DateOnly? EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
}