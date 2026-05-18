namespace SdxCore.Time.Application.DTOs;

public class BiometricDeviceDto
{
    public long Id { get; set; }
    public required string DeviceCode { get; set; }
    public required string DeviceName { get; set; }
    public string? SerialNumber { get; set; }
    public long? OfficeId { get; set; }
    public string? IpAddress { get; set; }
    public DateTime? LastSyncAt { get; set; }
    public bool IsActive { get; set; }
}

public class CreateBiometricDeviceDto
{
    public required string DeviceCode { get; set; }
    public required string DeviceName { get; set; }
    public string? SerialNumber { get; set; }
    public long? OfficeId { get; set; }
    public string? IpAddress { get; set; }
    public DateTime? LastSyncAt { get; set; }
}

public class UpdateBiometricDeviceDto : CreateBiometricDeviceDto { }
