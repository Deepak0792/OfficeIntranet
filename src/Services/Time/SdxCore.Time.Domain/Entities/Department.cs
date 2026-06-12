using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Time.Domain.Entities;

public class Department : BaseAuditEntity<Guid>, IPublishableEntity
{
    public required string DepartmentCode { get; set; }
    public required string DepartmentName { get; set; }

    /// <summary>Self-referencing FK — parent department in the hierarchy.</summary>
    public Guid? ParentDepartmentId { get; set; }

    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────

    /// <summary>Parent department in the hierarchy.</summary>
    public Department? ParentDepartment { get; set; }

    /// <summary>Child departments under this department.</summary>
    public ICollection<Department> ChildDepartments { get; set; } = new List<Department>();
}