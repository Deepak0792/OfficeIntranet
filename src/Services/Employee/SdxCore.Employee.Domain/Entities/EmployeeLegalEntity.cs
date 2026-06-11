using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeLegalEntity : BaseAuditEntity<Guid>, IPublishableEntity
{
    public Guid EmployeeId { get; set; }
    public Guid LegalEntityId { get; set; }
    public bool IsPrimaryLegalEntity { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool IsActive { get; set; } = true;
    public Employee Employee { get; set; } = null!;
}
