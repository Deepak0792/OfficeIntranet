namespace SdxCore.Time.Domain.DTOs;

public class LegalEntityDto
{
    public long Id { get; set; }
    public required string EntityCode { get; set; }
    public required string EntityName { get; set; }
    public long CountryId { get; set; }
    public string? TaxIdentificationNumber { get; set; }
    public string? RegistrationNumber { get; set; }
    public string? CurrencyCode { get; set; }
    public bool IsActive { get; set; }
}

public class CreateLegalEntityDto
{
    public required string EntityCode { get; set; }
    public required string EntityName { get; set; }
    public long CountryId { get; set; }
    public string? TaxIdentificationNumber { get; set; }
    public string? RegistrationNumber { get; set; }
    public string? CurrencyCode { get; set; }
}

public class UpdateLegalEntityDto : CreateLegalEntityDto { }
