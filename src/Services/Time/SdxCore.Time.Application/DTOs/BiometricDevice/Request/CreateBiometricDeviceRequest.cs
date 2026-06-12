namespace SdxCore.Time.Application.DTOs.BiometricDevice.Request;

public class CreateBiometricDeviceRequest
{
    public required string DeviceCode { get; set; }
    public required string DeviceName { get; set; }
    public string? SerialNumber { get; set; }
    public Guid? OfficeId { get; set; }
    public string? IpAddress { get; set; }
    public DateTime? LastSyncAt { get; set; }
}

