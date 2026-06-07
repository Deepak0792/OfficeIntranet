using System;

namespace SdxCore.Employee.Application.DTOs.Response;

public class EmployeeAddressResponse
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
    public string? CountryName { get; set; }
    public short? RegionId { get; set; }
    public string? RegionName { get; set; }
    public bool IsPrimaryAddress { get; set; }
    public int? WorkflowInstanceId { get; set; }
    public bool IsVerified { get; set; }
    public int? VerifiedByEmployeeId { get; set; }
    public DateTime? VerifiedAt { get; set; }
    public bool IsActive { get; set; }
}