namespace SdxCore.Time.Application.DTOs.GeoFence.Request;

public class CreateGeoFenceRequest
{
    public required string GeoFenceCode { get; set; }
    public required string GeoFenceName { get; set; }
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public decimal RadiusMeters { get; set; }
    public Guid? OfficeId { get; set; }
}

