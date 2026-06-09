namespace SdxCore.Time.Application.DTOs.Response;

public class GeoFenceResponse
{
    public Guid Id { get; set; }
    public required string GeoFenceCode { get; set; }
    public required string GeoFenceName { get; set; }
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public decimal RadiusMeters { get; set; }
    public Guid? OfficeId { get; set; }
    public bool IsActive { get; set; }
}

