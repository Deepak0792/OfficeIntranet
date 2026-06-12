using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Time.Domain.Entities;

public class Region : BaseAuditEntity<Guid>, IPublishableEntity
{
    public Guid CountryId { get; set; }
    public required string RegionName { get; set; }
    public string? RegionType { get; set; }

    /// <summary>Self-referencing FK — parent region in the hierarchy (e.g. State → Country subdivision).</summary>
    public Guid? ParentRegionId { get; set; }

    public short? DisplayOrder { get; set; }
    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────
    public Country? Country { get; set; }

    /// <summary>Parent region in the region hierarchy.</summary>
    public Region? ParentRegion { get; set; }

    /// <summary>Child regions under this region.</summary>
    public ICollection<Region> ChildRegions { get; set; } = new List<Region>();
}