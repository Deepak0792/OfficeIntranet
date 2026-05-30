using System;

namespace SdxCore.Employee.Application.DTOs.Request;

public class AddEmployeeRelationshipRequest
{
    public int ChildEmployeeId { get; set; }
    public string RelationshipType { get; set; } = null!;
    public short? DepartmentId { get; set; }
    public bool IsPrimaryRelationship { get; set; }
    public DateOnly? EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
}

public class UpdateEmployeeRelationshipRequest
{
    public string RelationshipType { get; set; } = null!;
    public short? DepartmentId { get; set; }
    public DateOnly? EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
}
