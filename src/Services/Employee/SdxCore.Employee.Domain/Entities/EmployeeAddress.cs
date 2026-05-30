using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeAddress : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public string AddressType { get; set; } = null!;
    public string AddressLine1 { get; set; } = null!;
    public string? AddressLine2 { get; set; }
    public string? Landmark { get; set; }
    public string City { get; set; } = null!;
    public string? StateProvince { get; set; }
    public string? PostalCode { get; set; }
    public short CountryId { get; set; }
    public short? RegionId { get; set; }
    public bool IsPrimary { get; set; }
    public int? WorkflowInstanceId { get; set; }
    public bool IsVerified { get; set; }
    public int? VerifiedByEmployeeId { get; set; }
    public DateTime? VerifiedAt { get; set; }
    public bool IsActive { get; set; }
}
