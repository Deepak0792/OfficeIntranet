namespace SdxCore.Time.Domain.DTOs.Response;

public class LegalEntityResponse
{
    public short Id { get; set; }
    public required string EntityCode { get; set; }
    public required string EntityName { get; set; }
    public short CountryId { get; set; }
    public string? TaxIdentificationNumber { get; set; }
    public string? RegistrationNumber { get; set; }
    public string? CurrencyCode { get; set; }
    public bool IsActive { get; set; }
}

