using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeContact : BaseAuditEntity<int>, IPublishableEntity
{
    public int EmployeeId { get; set; }
    public string ContactType { get; set; } = null!;
    public string ContactValue { get; set; } = null!;
    public bool IsPrimaryContact { get; set; }
    public bool IsActive { get; set; } = true;
}
