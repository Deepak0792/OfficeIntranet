using SdxCore.SharedKernel.Abstractions;
using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeAddress : BaseAuditEntity<Guid>, IPublishableEntity
{
    public Guid EmployeeId { get; set; }

    /// <summary>Lookup-backed address type (e.g. PERMANENT, CURRENT). FK to shared.StatusLookup.</summary>
    public string AddressType { get; set; } = null!;

    public string AddressLine1 { get; set; } = null!;
    public string? AddressLine2 { get; set; }
    public string? Landmark { get; set; }
    public string City { get; set; } = null!;
    public string? StateProvince { get; set; }
    public string? PostalCode { get; set; }

    /// <summary>Cross-schema FK to time.Country — stored as ID only, no nav prop.</summary>
    public Guid CountryId { get; set; }

    /// <summary>Cross-schema FK to time.Region — stored as ID only, no nav prop.</summary>
    public Guid? RegionId { get; set; }

    public bool IsPrimaryAddress { get; set; }

    /// <summary>Cross-schema FK to workflow.WorkflowInstance — stored as ID only, no nav prop.</summary>
    public Guid? WorkflowInstanceId { get; set; }

    public bool IsVerified { get; set; }

    /// <summary>Intra-schema FK to employee.Employee — the employee who verified this address.</summary>
    public Guid? VerifiedByEmployeeId { get; set; }
    public DateTime? VerifiedAt { get; set; }

    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────

    /// <summary>The employee who owns this address.</summary>
    public Employee Employee { get; set; } = null!;

    /// <summary>The employee who verified this address (optional, same schema).</summary>
    public Employee? VerifierEmployee { get; set; }
}
