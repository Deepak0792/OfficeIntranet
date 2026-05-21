namespace SdxCore.Time.Domain.Entities;
public class GeoFence : BaseEntity {
    public short Id { get; set; }
    public required string GeoFenceCode { get; set; }
    public required string GeoFenceName { get; set; }
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public decimal RadiusMeters { get; set; }
    public short? OfficeId { get; set; }
    public OfficeLocation? Office { get; set; }
}
