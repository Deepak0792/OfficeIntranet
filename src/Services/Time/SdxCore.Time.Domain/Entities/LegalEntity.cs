namespace SdxCore.Time.Domain.Entities;
public class LegalEntity : BaseEntity {
    public required string EntityCode { get; set; }
    public required string EntityName { get; set; }
    public long CountryId { get; set; }
    public string? TaxIdentificationNumber { get; set; }
    public string? RegistrationNumber { get; set; }
    public string? CurrencyCode { get; set; }
    public Country? Country { get; set; }
}
