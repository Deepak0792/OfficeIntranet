namespace SdxCore.Time.Application.DTOs.Response;

public class TimeZoneMasterResponse
{
    public Guid Id { get; set; }
    public required string TimeZoneCode { get; set; }
    public required string TimeZoneName { get; set; }
    public required string UtcOffset { get; set; }
    public short OffsetMinutes { get; set; }
    public bool SupportsDaylightSaving { get; set; }
    public string? WindowsTimeZoneId { get; set; }
    public string? IanaTimeZoneId { get; set; }
    public string? CountryCode { get; set; }
    public bool IsActive { get; set; }
}

