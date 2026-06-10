using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeLocation : BaseAuditEntity<Guid>, IPublishableEntity
{
    public Guid EmployeeId { get; set; }
    public Guid LocationId { get; set; }
    public bool IsPrimaryLocation { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool IsActive { get; set; } = true;
}
