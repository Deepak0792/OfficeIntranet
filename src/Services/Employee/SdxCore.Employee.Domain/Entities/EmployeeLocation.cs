using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeLocation : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short LocationId { get; set; }
    public bool IsPrimaryLocation { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}
