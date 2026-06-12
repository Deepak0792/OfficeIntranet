using System;

namespace SdxCore.Employee.Application.DTOs.EmployeeDepartment.Request;

public class CreateEmployeeDepartmentRequest
{
    public Guid DepartmentId { get; set; }
    public bool IsPrimaryDepartment { get; set; }
    public decimal? AllocationPercentage { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}