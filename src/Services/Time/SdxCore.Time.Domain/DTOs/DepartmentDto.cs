namespace SdxCore.Time.Domain.DTOs;

public class DepartmentDto
{
    public short Id { get; set; }
    public required string DepartmentCode { get; set; }
    public required string DepartmentName { get; set; }
    public short? ParentDepartmentId { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; }
}

public class CreateDepartmentDto
{
    public required string DepartmentCode { get; set; }
    public required string DepartmentName { get; set; }
    public short? ParentDepartmentId { get; set; }
    public string? Description { get; set; }
}

public class UpdateDepartmentDto : CreateDepartmentDto { }
