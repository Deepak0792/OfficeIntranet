namespace SdxCore.Employee.Application.DTOs.EmployeeAddress.Request;

public class UpdateEmployeeAddressRequest
{
    public string AddressLine1 { get; set; } = null!;
    public string? AddressLine2 { get; set; }
    public string? Landmark { get; set; }
    public string City { get; set; } = null!;
    public string? StateProvince { get; set; }
    public string? PostalCode { get; set; }

    /// <summary>Cross-schema FK to time.Country.</summary>
    public Guid CountryId { get; set; }

    /// <summary>Cross-schema FK to time.Region.</summary>
    public Guid? RegionId { get; set; }

    public bool IsPrimaryAddress { get; set; }
}
