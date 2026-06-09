using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Time.Domain.Entities;
public class Region : BaseAuditEntity<Guid>, IPublishableEntity
{
    public Guid CountryId { get; set; }
    public required string RegionName { get; set; }
    public string? RegionType { get; set; }
    public Guid? ParentRegionId { get; set; }
    public bool IsActive { get; set; } = true;
    public Country? Country { get; set; }
    public Region? ParentRegion { get; set; }
}