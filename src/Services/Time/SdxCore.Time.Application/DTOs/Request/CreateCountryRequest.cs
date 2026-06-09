namespace SdxCore.Time.Application.DTOs.Request;

public class CreateCountryRequest
{
    public required string CountryCode { get; set; }
    public required string CountryName { get; set; }
    public string? CurrencyCode { get; set; }
    public short? DisplayOrder { get; set; }
    public Guid? TimeZoneId { get; set; }
}

