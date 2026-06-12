using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeLegalEntity : BaseAuditEntity<Guid>, IPublishableEntity
{
    public Guid EmployeeId { get; set; }

    /// <summary>Cross-schema FK to time.LegalEntity — stored as ID only, no nav prop.</summary>
    public Guid LegalEntityId { get; set; }

    public bool IsPrimaryLegalEntity { get; set; }
    public DateOnly? StartDate { get; set; }
    public DateOnly? EndDate { get; set; }
    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────
    public Employee Employee { get; set; } = null!;
}
