namespace SdxCore.Time.Domain.Entities;
public class BiometricDevice : BaseEntity {
    public int Id { get; set; }
    public required string DeviceCode { get; set; }
    public required string DeviceName { get; set; }
    public string? SerialNumber { get; set; }
    public short? OfficeId { get; set; }
    public string? IpAddress { get; set; }
    public DateTime? LastSyncAt { get; set; }
    public OfficeLocation? Office { get; set; }
}
