namespace SdxCore.Time.Application.DTOs.Department.Response;

using System.Text.Json.Serialization;

public class DepartmentResponse
{
    public Guid Id { get; set; }
    public required string DepartmentCode { get; set; }
    public required string DepartmentName { get; set; }
    public Guid? ParentDepartmentId { get; set; }

    /// <summary>Denormalized — populated by application layer lookup.</summary>
    public string? ParentDepartmentName { get; set; }

    public string? Description { get; set; }
    public bool IsActive { get; set; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public List<DepartmentResponse>? Children { get; set; }
}
