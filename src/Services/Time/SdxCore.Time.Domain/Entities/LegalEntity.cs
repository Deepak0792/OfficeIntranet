using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Time.Domain.Entities;

public class LegalEntity : BaseAuditEntity<Guid>, IPublishableEntity
{
    public required string EntityCode { get; set; }
    public required string EntityName { get; set; }
    public Guid CountryId { get; set; }
    public string? TaxIdentificationNumber { get; set; }
    public string? RegistrationNumber { get; set; }
    public string? CurrencyCode { get; set; }
    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────
    public Country? Country { get; set; }

    /// <summary>Office locations registered under this legal entity.</summary>
    public ICollection<OfficeLocation> OfficeLocations { get; set; } = new List<OfficeLocation>();
}