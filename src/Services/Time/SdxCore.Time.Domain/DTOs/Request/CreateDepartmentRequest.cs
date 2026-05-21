namespace SdxCore.Time.Domain.DTOs.Request;

public class CreateDepartmentRequest
{
    public required string DepartmentCode { get; set; }
    public required string DepartmentName { get; set; }
    public short? ParentDepartmentId { get; set; }
    public string? Description { get; set; }
}

