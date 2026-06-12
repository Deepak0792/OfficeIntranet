namespace SdxCore.Time.Application.DTOs.Department.Request;

public class CreateDepartmentRequest
{
    public required string DepartmentCode { get; set; }
    public required string DepartmentName { get; set; }
    public Guid? ParentDepartmentId { get; set; }
    public string? Description { get; set; }
}

