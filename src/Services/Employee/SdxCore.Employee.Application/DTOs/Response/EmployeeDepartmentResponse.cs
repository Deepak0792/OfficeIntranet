using System;

namespace SdxCore.Employee.Application.DTOs.Response;

public class EmployeeDepartmentResponse
{
    public Guid Id { get; set; }
    public Guid EmployeeId { get; set; }
    public Guid DepartmentId { get; set; }
    public string? DepartmentName { get; set; }
    public bool IsPrimaryDepartment { get; set; }
    public decimal? AllocationPercentage { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool IsActive { get; set; }
}
