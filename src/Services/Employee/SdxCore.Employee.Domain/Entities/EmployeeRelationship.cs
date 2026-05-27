using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeRelationship : BaseEntity
{
    public int Id { get; set; }
    public int ParentEmployeeId { get; set; }
    public int ChildEmployeeId { get; set; }
    public string RelationshipType { get; set; } = string.Empty;
    public short? DepartmentId { get; set; }
    public bool IsPrimaryRelationship { get; set; } = false;
    public DateTime? EffectiveFrom { get; set; }
    public DateTime? EffectiveTo { get; set; }

    public Employee? ParentEmployee { get; set; }
    public Employee? ChildEmployee { get; set; }
}
