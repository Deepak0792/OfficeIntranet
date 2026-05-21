namespace SdxCore.Time.Domain.DTOs.Response;

public class DepartmentResponse
{
    public short Id { get; set; }
    public required string DepartmentCode { get; set; }
    public required string DepartmentName { get; set; }
    public short? ParentDepartmentId { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; }

    [System.Text.Json.Serialization.JsonIgnore(Condition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull)]
    public System.Collections.Generic.List<DepartmentResponse>? Children { get; set; }
}

