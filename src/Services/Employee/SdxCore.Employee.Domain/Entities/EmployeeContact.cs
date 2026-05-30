using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeContact : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public string ContactType { get; set; } = null!;
    public string ContactValue { get; set; } = null!;
    public bool IsPrimary { get; set; }
}
