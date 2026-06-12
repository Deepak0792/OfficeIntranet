namespace SdxCore.Time.Application.DTOs.LegalEntity.Response;

public class LegalEntityResponse
{
    public Guid Id { get; set; }
    public required string EntityCode { get; set; }
    public required string EntityName { get; set; }
    public Guid CountryId { get; set; }
    public string? TaxIdentificationNumber { get; set; }
    public string? RegistrationNumber { get; set; }
    public string? CurrencyCode { get; set; }
    public bool IsActive { get; set; }
}

