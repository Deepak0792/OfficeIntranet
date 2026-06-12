using System;

namespace SdxCore.Employee.Application.DTOs.EmployeeAddress.Response;

public class EmployeeAddressResponse
{
    public Guid Id { get; set; }
    public Guid EmployeeId { get; set; }
    public string AddressType { get; set; } = null!;
    public string AddressLine1 { get; set; } = null!;
    public string? AddressLine2 { get; set; }
    public string? Landmark { get; set; }
    public string City { get; set; } = null!;
    public string? StateProvince { get; set; }
    public string? PostalCode { get; set; }
    public Guid CountryId { get; set; }
    public string? CountryName { get; set; }
    public Guid? RegionId { get; set; }
    public string? RegionName { get; set; }
    public bool IsPrimaryAddress { get; set; }
    public Guid? WorkflowInstanceId { get; set; }
    public bool IsVerified { get; set; }
    public Guid? VerifiedByEmployeeId { get; set; }
    public DateTime? VerifiedAt { get; set; }
    public bool IsActive { get; set; }
}