using SdxCore.SharedKernel.Entities;

namespace SdxCore.Time.Domain.Entities;
public class BiometricDevice : BaseAuditEntity<Guid>
{
    public required string DeviceCode { get; set; }
    public required string DeviceName { get; set; }
    public string? SerialNumber { get; set; }
    public Guid? OfficeId { get; set; }
    public string? IpAddress { get; set; }
    public DateTime? LastSyncAt { get; set; }
    public bool IsActive { get; set; } = true;
    public OfficeLocation? Office { get; set; }
}