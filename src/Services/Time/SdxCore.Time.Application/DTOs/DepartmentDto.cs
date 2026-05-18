namespace SdxCore.Time.Application.DTOs;

public class DepartmentDto
{
    public long Id { get; set; }
    public required string DepartmentCode { get; set; }
    public required string DepartmentName { get; set; }
    public long? ParentDepartmentId { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; }
}

public class CreateDepartmentDto
{
    public required string DepartmentCode { get; set; }
    public required string DepartmentName { get; set; }
    public long? ParentDepartmentId { get; set; }
    public string? Description { get; set; }
}

public class UpdateDepartmentDto : CreateDepartmentDto { }
