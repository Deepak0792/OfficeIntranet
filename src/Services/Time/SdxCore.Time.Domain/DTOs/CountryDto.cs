namespace SdxCore.Time.Domain.DTOs;

public class CountryDto
{
    public short Id { get; set; }
    public required string CountryCode { get; set; }
    public required string CountryName { get; set; }
    public string? CurrencyCode { get; set; }
    public short? DisplayOrder { get; set; }
    public short? TimeZoneId { get; set; }
    public bool IsActive { get; set; }
}

public class CreateCountryDto
{
    public required string CountryCode { get; set; }
    public required string CountryName { get; set; }
    public string? CurrencyCode { get; set; }
    public short? DisplayOrder { get; set; }
    public short? TimeZoneId { get; set; }
}

public class UpdateCountryDto : CreateCountryDto { }
