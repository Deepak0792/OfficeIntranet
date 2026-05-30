using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeDepartment : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short DepartmentId { get; set; }
    public bool IsPrimaryDepartment { get; set; }
    public decimal? AllocationPercentage { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}
