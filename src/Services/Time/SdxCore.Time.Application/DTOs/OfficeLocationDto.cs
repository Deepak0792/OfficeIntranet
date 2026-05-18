namespace SdxCore.Time.Application.DTOs;

public class OfficeLocationDto
{
    public long Id { get; set; }
    public long LegalEntityId { get; set; }
    public long CountryId { get; set; }
    public long? RegionId { get; set; }
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
    public long? TimeZoneId { get; set; }
    public bool IsHeadOffice { get; set; }
    public bool IsActive { get; set; }
}

public class CreateOfficeLocationDto
{
    public long LegalEntityId { get; set; }
    public long CountryId { get; set; }
    public long? RegionId { get; set; }
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
    public long? TimeZoneId { get; set; }
    public bool IsHeadOffice { get; set; }
}

public class UpdateOfficeLocationDto : CreateOfficeLocationDto { }
