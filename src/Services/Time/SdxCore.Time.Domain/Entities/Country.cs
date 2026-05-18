namespace SdxCore.Time.Domain.Entities;
public class Country : BaseEntity {
    public required string CountryCode { get; set; }
    public required string CountryName { get; set; }
    public string? CurrencyCode { get; set; }
    public long? TimeZoneId { get; set; }
    public TimeZoneMaster? TimeZone { get; set; }
}
