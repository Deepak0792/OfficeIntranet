using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Time.Domain.Entities;
public class OfficeLocation : BaseAuditEntity<Guid>, IPublishableEntity
{
    public Guid LegalEntityId { get; set; }
    public Guid CountryId { get; set; }
    public Guid? RegionId { get; set; }
    public required string LocationCode { get; set; }
    public required string LocationName { get; set; }
    public string? BuildingName { get; set; }
    public string? AddressLine1 { get; set; }
    public string? AddressLine2 { get; set; }
    public string? City { get; set; }
    public string? StateProvince { get; set; }
    public string? PostalCode { get; set; }
    public decimal? Latitude { get; set; }
    public decimal? Longitude { get; set; }
    public Guid? TimeZoneId { get; set; }
    public bool IsHeadOffice { get; set; }
    public bool IsActive { get; set; } = true;
    public LegalEntity? LegalEntity { get; set; }
    public Country? Country { get; set; }
    public Region? Region { get; set; }
    public TimeZoneMaster? TimeZone { get; set; }
}