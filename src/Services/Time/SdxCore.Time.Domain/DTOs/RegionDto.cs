namespace SdxCore.Time.Domain.DTOs;

public class RegionDto
{
    public short Id { get; set; }
    public short CountryId { get; set; }
    public required string RegionName { get; set; }
    public string? RegionType { get; set; }
    public short? ParentRegionId { get; set; }
    public bool IsActive { get; set; }
}

public class CreateRegionDto
{
    public short CountryId { get; set; }
    public required string RegionName { get; set; }
    public string? RegionType { get; set; }
    public short? ParentRegionId { get; set; }
}

public class UpdateRegionDto : CreateRegionDto { }
