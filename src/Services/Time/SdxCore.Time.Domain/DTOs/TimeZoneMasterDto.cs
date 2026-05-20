namespace SdxCore.Time.Domain.DTOs;

public class TimeZoneMasterDto
{
    public long Id { get; set; }
    public required string TimeZoneCode { get; set; }
    public required string TimeZoneName { get; set; }
    public required string UtcOffset { get; set; }
    public int OffsetMinutes { get; set; }
    public bool SupportsDaylightSaving { get; set; }
    public string? WindowsTimeZoneId { get; set; }
    public string? IanaTimeZoneId { get; set; }
    public string? CountryCode { get; set; }
    public bool IsActive { get; set; }
}

public class CreateTimeZoneMasterDto
{
    public required string TimeZoneCode { get; set; }
    public required string TimeZoneName { get; set; }
    public required string UtcOffset { get; set; }
    public int OffsetMinutes { get; set; }
    public bool SupportsDaylightSaving { get; set; }
    public string? WindowsTimeZoneId { get; set; }
    public string? IanaTimeZoneId { get; set; }
    public string? CountryCode { get; set; }
}

public class UpdateTimeZoneMasterDto : CreateTimeZoneMasterDto { }
