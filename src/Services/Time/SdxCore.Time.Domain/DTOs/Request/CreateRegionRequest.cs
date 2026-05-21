namespace SdxCore.Time.Domain.DTOs.Request;

public class CreateRegionRequest
{
    public short CountryId { get; set; }
    public required string RegionName { get; set; }
    public string? RegionType { get; set; }
    public short? ParentRegionId { get; set; }
}

