using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeLocation : BaseAuditEntity<Guid>, IPublishableEntity
{
    public Guid EmployeeId { get; set; }

    /// <summary>Cross-schema FK to time.OfficeLocation — stored as ID only, no nav prop.</summary>
    public Guid LocationId { get; set; }

    public bool IsPrimaryLocation { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────
    public Employee Employee { get; set; } = null!;
}
