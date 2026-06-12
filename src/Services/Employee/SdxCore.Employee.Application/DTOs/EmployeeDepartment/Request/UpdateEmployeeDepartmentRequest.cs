namespace SdxCore.Employee.Application.DTOs.EmployeeDepartment.Request;

public class UpdateEmployeeDepartmentRequest
{
    /// <summary>Cross-schema FK to time.Department. Allows reassigning the department.</summary>
    public Guid DepartmentId { get; set; }
    public bool IsPrimaryDepartment { get; set; }
    public decimal? AllocationPercentage { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}