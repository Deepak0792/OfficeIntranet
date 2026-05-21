namespace SdxCore.Time.Domain.DTOs.Response;

public class BiometricDeviceResponse
{
    public int Id { get; set; }
    public required string DeviceCode { get; set; }
    public required string DeviceName { get; set; }
    public string? SerialNumber { get; set; }
    public short? OfficeId { get; set; }
    public string? IpAddress { get; set; }
    public DateTime? LastSyncAt { get; set; }
    public bool IsActive { get; set; }
}

