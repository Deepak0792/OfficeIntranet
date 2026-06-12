using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Time.Domain.Entities;

public class GeoFence : BaseAuditEntity<Guid>, IPublishableEntity
{
    public required string GeoFenceCode { get; set; }
    public required string GeoFenceName { get; set; }
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public decimal RadiusMeters { get; set; }

    /// <summary>Intra-schema FK to time.OfficeLocation — the office this geo-fence is attached to.</summary>
    public Guid? OfficeId { get; set; }

    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────
    public OfficeLocation? Office { get; set; }
}