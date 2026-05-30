namespace SdxCore.Time.Application.DTOs.Response;

public class RegionResponse
{
    public short Id { get; set; }
    public short CountryId { get; set; }
    public required string RegionName { get; set; }
    public string? RegionType { get; set; }
    public short? ParentRegionId { get; set; }
    public bool IsActive { get; set; }

    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull)]
    public System.Collections.Generic.List<RegionResponse>? Children { get; set; }
}

