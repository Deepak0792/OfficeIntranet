namespace SdxCore.Employee.Application.DTOs.Response;

public class EmployeeSummaryResponse
{
    public int Id { get; set; }
    public string EmployeeCode { get; set; } = null!;
    public string DisplayName { get; set; } = null!;
    public string? ProfilePhotoUrl { get; set; }
    public string Email { get; set; } = null!;
    public string? DesignationName { get; set; }
    public string? PrimaryDepartmentName { get; set; }
    public string? PrimaryLocationName { get; set; }
    public bool IsActive { get; set; }
}
