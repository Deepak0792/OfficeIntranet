using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeLegalEntity : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short LegalEntityId { get; set; }
    public bool IsPrimary { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}
