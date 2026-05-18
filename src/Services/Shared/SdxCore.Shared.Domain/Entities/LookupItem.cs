using System.Text.Json.Serialization;

namespace SdxCore.Shared.Domain.Entities;

public class LookupItem
{
    [JsonPropertyName("id")]
    public string Id { get; set; } = string.Empty;

    [JsonPropertyName("idType")]
    public string IdType { get; set; } = "string";

    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;

    [JsonPropertyName("displayOrder")]
    public int DisplayOrder { get; set; }
}
