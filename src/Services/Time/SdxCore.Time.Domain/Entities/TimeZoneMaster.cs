using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Time.Domain.Entities;

public class TimeZoneMaster : BaseAuditEntity<Guid>, IPublishableEntity
{
    public required string TimeZoneCode { get; set; }
    public required string TimeZoneName { get; set; }
    public required string UtcOffset { get; set; }
    public short OffsetMinutes { get; set; }
    public bool SupportsDaylightSaving { get; set; }
    public string? WindowsTimeZoneId { get; set; }
    public string? IanaTimeZoneId { get; set; }
    public string? CountryCode { get; set; }
    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────

    /// <summary>Countries that use this timezone as their primary timezone.</summary>
    public ICollection<Country> Countries { get; set; } = new List<Country>();
}