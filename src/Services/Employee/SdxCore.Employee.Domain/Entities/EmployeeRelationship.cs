using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeRelationship : BaseEntity
{
    public int Id { get; set; }
    public int ParentEmployeeId { get; set; }
    public int ChildEmployeeId { get; set; }
    public string RelationshipType { get; set; } = null!;
    public short? DepartmentId { get; set; }
    public bool IsPrimaryRelationship { get; set; }
    public DateOnly? EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
}
