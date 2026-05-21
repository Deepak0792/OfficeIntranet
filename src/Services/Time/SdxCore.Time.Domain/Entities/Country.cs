namespace SdxCore.Time.Domain.Entities;
public class Country : BaseEntity {
    public short Id { get; set; }
    public required string CountryCode { get; set; }
    public required string CountryName { get; set; }
    public string? CurrencyCode { get; set; }
    public short? DisplayOrder { get; set; }
    public short? TimeZoneId { get; set; }
    public TimeZoneMaster? TimeZone { get; set; }
}
