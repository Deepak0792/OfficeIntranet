using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeDepartment : BaseAuditEntity<Guid>, IPublishableEntity
{
    public Guid EmployeeId { get; set; }

    /// <summary>Cross-schema FK to time.Department — stored as ID only, no nav prop.</summary>
    public Guid DepartmentId { get; set; }

    public bool IsPrimaryDepartment { get; set; }
    public decimal? AllocationPercentage { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────
    public Employee Employee { get; set; } = null!;
}
