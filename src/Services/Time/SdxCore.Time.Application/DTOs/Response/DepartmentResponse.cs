namespace SdxCore.Time.Application.DTOs.Response;
using System.Text.Json.Serialization;
using System.Collections.Generic;

public class DepartmentResponse
{
    public Guid Id { get; set; }
    public required string DepartmentCode { get; set; }
    public required string DepartmentName { get; set; }
    public Guid? ParentDepartmentId { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public List<DepartmentResponse>? Children { get; set; }
}

