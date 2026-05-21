namespace SdxCore.Time.Domain.DTOs.Request;

public class CreateTimeZoneMasterRequest
{
    public required string TimeZoneCode { get; set; }
    public required string TimeZoneName { get; set; }
    public required string UtcOffset { get; set; }
    public short OffsetMinutes { get; set; }
    public bool SupportsDaylightSaving { get; set; }
    public string? WindowsTimeZoneId { get; set; }
    public string? IanaTimeZoneId { get; set; }
    public string? CountryCode { get; set; }
}

