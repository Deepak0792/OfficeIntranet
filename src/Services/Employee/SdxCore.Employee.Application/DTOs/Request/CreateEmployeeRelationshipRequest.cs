using System;

namespace SdxCore.Employee.Application.DTOs.Request;

public class CreateEmployeeRelationshipRequest
{
    public int ChildEmployeeId { get; set; }
    public string RelationshipType { get; set; } = null!;
    public short? DepartmentId { get; set; }
    public bool IsPrimaryRelationship { get; set; }
    public DateOnly? EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
}