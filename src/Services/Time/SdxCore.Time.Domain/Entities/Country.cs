using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Time.Domain.Entities;

public class Country : BaseAuditEntity<Guid>, IPublishableEntity
{
    public required string CountryCode { get; set; }
    public required string CountryName { get; set; }
    public string? CurrencyCode { get; set; }

    /// <summary>Intra-schema FK to time.TimeZoneMaster — default timezone for this country.</summary>
    public Guid? TimeZoneId { get; set; }

    public short? DisplayOrder { get; set; }
    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────
    public TimeZoneMaster? TimeZone { get; set; }

    /// <summary>Regions that belong to this country.</summary>
    public ICollection<Region> Regions { get; set; } = new List<Region>();

    /// <summary>Legal entities registered in this country.</summary>
    public ICollection<LegalEntity> LegalEntities { get; set; } = new List<LegalEntity>();

    /// <summary>Office locations in this country.</summary>
    public ICollection<OfficeLocation> OfficeLocations { get; set; } = new List<OfficeLocation>();
}