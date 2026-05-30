namespace SdxCore.Time.Application.DTOs.Response;

public class GeoFenceResponse
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

