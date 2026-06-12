namespace SdxCore.Employee.Application.DTOs.EmployeeLegalEntity.Request;

public class UpdateEmployeeLegalEntityRequest
{
    /// <summary>Cross-schema FK to time.LegalEntity. Allows reassigning the legal entity.</summary>
    public Guid LegalEntityId { get; set; }
    public bool IsPrimaryLegalEntity { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}