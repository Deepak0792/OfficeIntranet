using System;

namespace SdxCore.Employee.Application.DTOs.Request;

public class CreateEmployeeLegalEntityRequest
{
    public Guid LegalEntityId { get; set; }
    public bool IsPrimaryLegalEntity { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}
