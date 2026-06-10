namespace SdxCore.Employee.Application.DTOs.Response;

public class EmployeeLegalEntityResponse
{
    public Guid Id { get; set; }
    public Guid EmployeeId { get; set; }
    public Guid LegalEntityId { get; set; }
    public string? LegalEntityName { get; set; }
    public bool IsPrimaryLegalEntity { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool IsActive { get; set; }
}