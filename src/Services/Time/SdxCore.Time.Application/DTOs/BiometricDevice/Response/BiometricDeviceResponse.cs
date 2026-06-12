namespace SdxCore.Time.Application.DTOs.BiometricDevice.Response;

public class BiometricDeviceResponse
{
    public Guid Id { get; set; }
    public required string DeviceCode { get; set; }
    public required string DeviceName { get; set; }
    public string? SerialNumber { get; set; }
    public Guid? OfficeId { get; set; }

    /// <summary>Denormalized — populated by application layer lookup.</summary>
    public string? OfficeName { get; set; }

    public string? IpAddress { get; set; }
    public DateTime? LastSyncAt { get; set; }
    public bool IsActive { get; set; }
}
