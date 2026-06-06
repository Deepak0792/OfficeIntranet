using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeLegalEntity : BaseAuditEntity<int>, IPublishableEntity
{
    public int EmployeeId { get; set; }
    public short LegalEntityId { get; set; }
    public bool IsPrimary { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool IsActive { get; set; } = true;
}
