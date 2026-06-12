using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;

public class EmployeeBiometricMapping : BaseAuditEntity<Guid>
{
    public Guid EmployeeId { get; set; }

    /// <summary>Cross-schema FK to time.BiometricDevice — stored as ID only, no nav prop.</summary>
    public Guid BiometricDeviceId { get; set; }

    public required string DeviceEmployeeCode { get; set; }
    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────
    public Employee Employee { get; set; } = null!;
}
