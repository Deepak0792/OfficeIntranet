using System;

namespace SdxCore.Employee.Application.DTOs.EmployeeAddress.Request;

public class CreateEmployeeAddressRequest
{
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
}