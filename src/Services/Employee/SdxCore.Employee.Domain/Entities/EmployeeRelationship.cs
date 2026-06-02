using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeRelationship : BaseAuditEntity<int>, IPublishableEntity
{
    public int ParentEmployeeId { get; set; }
    public int ChildEmployeeId { get; set; }
    public string RelationshipType { get; set; } = null!;
    public short? DepartmentId { get; set; }
    public bool IsPrimaryRelationship { get; set; }
    public DateOnly? EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
}
