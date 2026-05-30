namespace SdxCore.Employee.Application.DTOs.Request;

public class AddBiometricMappingRequest
{
    public int BiometricDeviceId { get; set; }
    public required string DeviceEmployeeCode { get; set; }
}
