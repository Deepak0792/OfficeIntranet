using System.Text.Json.Serialization;

namespace SdxCore.Shared.Domain.Entities;

public class LookupItem
{
    [JsonPropertyName("id")]
    public Guid Id { get; set; }

    [JsonPropertyName("idType")]
    public string IdType { get; set; } = "guid";

    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;

    [JsonPropertyName("displayOrder")]
    public short DisplayOrder { get; set; }
}
