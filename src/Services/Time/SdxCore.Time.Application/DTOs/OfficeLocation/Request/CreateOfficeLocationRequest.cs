namespace SdxCore.Time.Application.DTOs.OfficeLocation.Request;

public class CreateOfficeLocationRequest
{
    public Guid LegalEntityId { get; set; }
    public Guid CountryId { get; set; }
    public Guid? RegionId { get; set; }
    public required string LocationCode { get; set; }
    public required string LocationName { get; set; }
    public string? BuildingName { get; set; }
    public string? AddressLine1 { get; set; }
    public string? AddressLine2 { get; set; }
    public string? City { get; set; }
    public string? StateProvince { get; set; }
    public string? PostalCode { get; set; }
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }
    public Guid? TimeZoneId { get; set; }
    public bool IsHeadOffice { get; set; }
}

