using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Time.Domain.Entities;
public class LegalEntity : BaseAuditEntity<short>, IPublishableEntity
{
    public required string EntityCode { get; set; }
    public required string EntityName { get; set; }
    public short CountryId { get; set; }
    public string? TaxIdentificationNumber { get; set; }
    public string? RegistrationNumber { get; set; }
    public string? CurrencyCode { get; set; }
    public Country? Country { get; set; }
}
