using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeContact : BaseAuditEntity<Guid>, IPublishableEntity
{
    public Guid EmployeeId { get; set; }

    /// <summary>Lookup-backed contact type (e.g. PHONE, EMAIL). FK to shared.StatusLookup.</summary>
    public string ContactType { get; set; } = null!;

    public string ContactValue { get; set; } = null!;
    public bool IsPrimaryContact { get; set; }
    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────
    public Employee Employee { get; set; } = null!;
}
