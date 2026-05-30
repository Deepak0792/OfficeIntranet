using System;

namespace SdxCore.Employee.Application.DTOs.Request;

public class AddEmployeeDepartmentRequest
{
    public short DepartmentId { get; set; }
    public bool IsPrimaryDepartment { get; set; }
    public decimal? AllocationPercentage { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}

public class UpdateEmployeeDepartmentRequest
{
    public decimal? AllocationPercentage { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}
