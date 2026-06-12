using SdxCore.SharedKernel.Entities;

namespace SdxCore.Time.Domain.Entities;

public class BiometricDevice : BaseAuditEntity<Guid>
{
    public required string DeviceCode { get; set; }
    public required string DeviceName { get; set; }
    public string? SerialNumber { get; set; }

    /// <summary>Intra-schema FK to time.OfficeLocation — the office where this device is installed.</summary>
    public Guid? OfficeId { get; set; }

    public string? IpAddress { get; set; }
    public DateTime? LastSyncAt { get; set; }
    public bool IsActive { get; set; } = true;

    // ── Intra-schema navigation properties ────────────────────────────────────
    public OfficeLocation? Office { get; set; }
}