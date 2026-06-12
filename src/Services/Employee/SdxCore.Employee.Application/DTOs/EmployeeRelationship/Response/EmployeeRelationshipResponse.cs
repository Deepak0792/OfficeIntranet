namespace SdxCore.Employee.Application.DTOs.EmployeeRelationship.Response;

public class EmployeeRelationshipResponse
{
    public Guid Id { get; set; }
    public Guid ParentEmployeeId { get; set; }
    public Guid ChildEmployeeId { get; set; }
    public string? ChildEmployeeName { get; set; }
    public string? ParentEmployeeName { get; set; }
    public string RelationshipType { get; set; } = null!;
    public Guid? DepartmentId { get; set; }
    public bool IsPrimaryRelationship { get; set; }
    public DateOnly? EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
    public bool IsActive { get; set; }
}
