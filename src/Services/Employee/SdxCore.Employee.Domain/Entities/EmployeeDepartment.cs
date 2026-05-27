using System;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeDepartment : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short DepartmentId { get; set; }
    public bool IsPrimaryDepartment { get; set; } = false;
    public decimal? AllocationPercentage { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }

    public Employee? Employee { get; set; }
}
