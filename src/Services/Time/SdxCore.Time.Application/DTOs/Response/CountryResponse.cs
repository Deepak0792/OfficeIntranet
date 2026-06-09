namespace SdxCore.Time.Application.DTOs.Response;

public class CountryResponse
{
    public Guid Id { get; set; }
    public required string CountryCode { get; set; }
    public required string CountryName { get; set; }
    public string? CurrencyCode { get; set; }
    public short? DisplayOrder { get; set; }
    public Guid? TimeZoneId { get; set; }
    public bool IsActive { get; set; }
}

