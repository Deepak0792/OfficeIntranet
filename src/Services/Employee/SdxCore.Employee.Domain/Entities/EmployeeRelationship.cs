using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeRelationship : BaseAuditEntity<Guid>, IPublishableEntity
{
    public Guid ParentEmployeeId { get; set; }
    public Guid ChildEmployeeId { get; set; }
    public string RelationshipType { get; set; } = null!;
    public Guid? DepartmentId { get; set; }
    public bool IsPrimaryRelationship { get; set; }
    public DateOnly? EffectiveFrom { get; set; }
    public DateOnly? EffectiveTo { get; set; }
    public bool IsActive { get; set; } = true;
}
