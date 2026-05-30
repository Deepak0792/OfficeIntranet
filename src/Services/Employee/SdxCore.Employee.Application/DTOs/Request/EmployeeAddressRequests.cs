using System;

namespace SdxCore.Employee.Application.DTOs.Request;

public class AddEmployeeAddressRequest
{
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
}

public class UpdateEmployeeAddressRequest
{
    public string AddressLine1 { get; set; } = null!;
    public string? AddressLine2 { get; set; }
    public string? Landmark { get; set; }
    public string City { get; set; } = null!;
    public string? StateProvince { get; set; }
    public string? PostalCode { get; set; }
    public short CountryId { get; set; }
    public short? RegionId { get; set; }
}
