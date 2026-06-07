using System;

namespace SdxCore.Employee.Application.DTOs.Response;

public class EmployeeLegalEntityResponse
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short LegalEntityId { get; set; }
    public string? LegalEntityName { get; set; }
    public bool IsPrimaryLegalEntity { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool IsActive { get; set; }
}