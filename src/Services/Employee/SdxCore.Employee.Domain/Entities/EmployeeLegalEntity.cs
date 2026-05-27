using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeLegalEntity : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short LegalEntityId { get; set; }
    public bool IsPrimary { get; set; } = false;
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }

    public Employee? Employee { get; set; }
}
