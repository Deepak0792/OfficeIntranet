namespace SdxCore.Employee.Application.DTOs.EmployeeRelationship.Request;

public class UpdateEmployeeRelationshipRequest
{
    /// <summary>Lookup code from shared.StatusLookup under group RELATIONSHIP_TYPE.</summary>
    public string RelationshipType { get; set; } = null!;

    /// <summary>Optional department context. Cross-schema FK to time.Department.</summary>
    public Guid? DepartmentId { get; set; }

    public bool IsPrimaryRelationship { get; set; }
    public DateOnly? EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
}
