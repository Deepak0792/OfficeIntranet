using System;

namespace SdxCore.Employee.Application.DTOs.Response;

public class EmployeeDepartmentResponse
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public short DepartmentId { get; set; }
    public string? DepartmentName { get; set; }
    public bool IsPrimaryDepartment { get; set; }
    public decimal? AllocationPercentage { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool IsActive { get; set; }
}
