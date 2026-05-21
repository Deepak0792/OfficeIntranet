namespace SdxCore.Time.Domain.DTOs;

public class OfficeLocationDto
{
    public short Id { get; set; }
    public short LegalEntityId { get; set; }
    public short CountryId { get; set; }
    public short? RegionId { get; set; }
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
    public short? TimeZoneId { get; set; }
    public bool IsHeadOffice { get; set; }
    public bool IsActive { get; set; }
}

public class CreateOfficeLocationDto
{
    public short LegalEntityId { get; set; }
    public short CountryId { get; set; }
    public short? RegionId { get; set; }
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
    public short? TimeZoneId { get; set; }
    public bool IsHeadOffice { get; set; }
}

public class UpdateOfficeLocationDto : CreateOfficeLocationDto { }
