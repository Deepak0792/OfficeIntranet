using System;

namespace SdxCore.Employee.Application.DTOs.Request;

public class CreateEmployeeLegalEntityRequest
{
    public short LegalEntityId { get; set; }
    public bool IsPrimary { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}
