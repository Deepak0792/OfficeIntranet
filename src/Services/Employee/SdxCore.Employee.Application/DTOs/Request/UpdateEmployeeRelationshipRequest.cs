namespace SdxCore.Employee.Application.DTOs.Request;

public class UpdateEmployeeRelationshipRequest
{
    public string RelationshipType { get; set; } = null!;
    public short? DepartmentId { get; set; }
    public DateOnly? EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
}

