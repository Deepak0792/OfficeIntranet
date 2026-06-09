namespace SdxCore.Time.Application.DTOs.Request;

public class CreateLegalEntityRequest
{
    public required string EntityCode { get; set; }
    public required string EntityName { get; set; }
    public Guid CountryId { get; set; }
    public string? TaxIdentificationNumber { get; set; }
    public string? RegistrationNumber { get; set; }
    public string? CurrencyCode { get; set; }
}

