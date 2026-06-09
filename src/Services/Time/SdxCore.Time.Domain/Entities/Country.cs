using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Time.Domain.Entities;
public class Country : BaseAuditEntity<Guid>, IPublishableEntity
{
    public required string CountryCode { get; set; }
    public required string CountryName { get; set; }
    public string? CurrencyCode { get; set; }
    public short? DisplayOrder { get; set; }
    public Guid? TimeZoneId { get; set; }
    public bool IsActive { get; set; } = true;
    public TimeZoneMaster? TimeZone { get; set; }    
}