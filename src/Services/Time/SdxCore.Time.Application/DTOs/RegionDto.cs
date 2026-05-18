namespace SdxCore.Time.Application.DTOs;

public class RegionDto
{
    public long Id { get; set; }
    public long CountryId { get; set; }
    public required string RegionName { get; set; }
    public string? RegionType { get; set; }
    public long? ParentRegionId { get; set; }
    public bool IsActive { get; set; }
}

public class CreateRegionDto
{
    public long CountryId { get; set; }
    public required string RegionName { get; set; }
    public string? RegionType { get; set; }
    public long? ParentRegionId { get; set; }
}

public class UpdateRegionDto : CreateRegionDto { }
