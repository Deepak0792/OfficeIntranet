using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeLocation : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short LocationId { get; set; }
    public bool IsPrimaryLocation { get; set; } = true;
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }

    public Employee? Employee { get; set; }
}
