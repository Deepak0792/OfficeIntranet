namespace SdxCore.Time.Application.DTOs.Response;
using System.Text.Json.Serialization;
using System.Collections.Generic;

public class RegionResponse
{
    public Guid Id { get; set; }
    public Guid CountryId { get; set; }
    public required string RegionName { get; set; }
    public string? RegionType { get; set; }
    public Guid? ParentRegionId { get; set; }
    public bool IsActive { get; set; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public List<RegionResponse>? Children { get; set; }
}

