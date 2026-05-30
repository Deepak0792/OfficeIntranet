namespace SdxCore.Employee.Application.DTOs.Response;

public class EmployeeSummaryResponse
{
    public int Id { get; set; }
    public string EmployeeCode { get; set; } = null!;
    public string DisplayName { get; set; } = null!;
    public string? ProfilePhotoUrl { get; set; }
    public string Email { get; set; } = null!;
    public string? DesignationName { get; set; }
    public string? DepartmentName { get; set; }
    public string? LocationName { get; set; }
    public bool IsActive { get; set; }
}
