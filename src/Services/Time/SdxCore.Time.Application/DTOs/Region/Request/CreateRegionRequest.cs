namespace SdxCore.Time.Application.DTOs.Region.Request;

public class CreateRegionRequest
{
    public Guid CountryId { get; set; }
    public required string RegionName { get; set; }
    public string? RegionType { get; set; }
    public Guid? ParentRegionId { get; set; }
    public short? DisplayOrder { get; set; }
}
