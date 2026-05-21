namespace SdxCore.Time.Domain.DTOs;

public class GeoFenceDto
{
    public short Id { get; set; }
    public required string GeoFenceCode { get; set; }
    public required string GeoFenceName { get; set; }
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public decimal RadiusMeters { get; set; }
    public short? OfficeId { get; set; }
    public bool IsActive { get; set; }
}

public class CreateGeoFenceDto
{
    public required string GeoFenceCode { get; set; }
    public required string GeoFenceName { get; set; }
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public decimal RadiusMeters { get; set; }
    public short? OfficeId { get; set; }
}

public class UpdateGeoFenceDto : CreateGeoFenceDto { }
