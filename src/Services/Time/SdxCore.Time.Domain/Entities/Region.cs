namespace SdxCore.Time.Domain.Entities;
public class Region : BaseEntity {
    public short Id { get; set; }
    public short CountryId { get; set; }
    public required string RegionName { get; set; }
    public string? RegionType { get; set; }
    public short? ParentRegionId { get; set; }
    public Country? Country { get; set; }
    public Region? ParentRegion { get; set; }
}
