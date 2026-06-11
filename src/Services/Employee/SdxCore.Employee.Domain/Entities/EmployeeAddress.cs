using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeAddress : BaseAuditEntity<Guid>, IPublishableEntity
{
    public Guid EmployeeId { get; set; }
    public string AddressType { get; set; } = null!;
    public string AddressLine1 { get; set; } = null!;
    public string? AddressLine2 { get; set; }
    public string? Landmark { get; set; }
    public string City { get; set; } = null!;
    public string? StateProvince { get; set; }
    public string? PostalCode { get; set; }
    public Guid CountryId { get; set; }
    public Guid? RegionId { get; set; }
    public bool IsPrimaryAddress { get; set; }
    public Guid? WorkflowInstanceId { get; set; }
    public bool IsVerified { get; set; }
    public Guid? VerifiedByEmployeeId { get; set; }
    public DateTime? VerifiedAt { get; set; }
    public bool IsActive { get; set; } = true;
    public Employee Employee { get; set; } = null!;
}
