using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Time.Domain.Entities;
public class Department : BaseAuditEntity<Guid>, IPublishableEntity
{
    public required string DepartmentCode { get; set; }
    public required string DepartmentName { get; set; }
    public Guid? ParentDepartmentId { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;
    public Department? ParentDepartment { get; set; }
}