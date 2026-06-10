using System;

namespace SdxCore.Employee.Application.DTOs.Request;

public class CreateEmployeeRelationshipRequest
{
    public Guid ChildEmployeeId { get; set; }
    public string RelationshipType { get; set; } = null!;
    public Guid? DepartmentId { get; set; }
    public bool IsPrimaryRelationship { get; set; }
    public DateOnly? EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
}