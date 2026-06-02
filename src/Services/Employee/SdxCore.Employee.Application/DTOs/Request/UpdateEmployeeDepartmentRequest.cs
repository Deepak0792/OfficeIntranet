namespace SdxCore.Employee.Application.DTOs.Request;

public class UpdateEmployeeDepartmentRequest
{
    public decimal? AllocationPercentage { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
}