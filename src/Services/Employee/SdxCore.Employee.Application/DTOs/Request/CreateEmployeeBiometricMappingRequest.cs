namespace SdxCore.Employee.Application.DTOs.Request;

public class CreateEmployeeBiometricMappingRequest
{
    public Guid BiometricDeviceId { get; set; }
    public required string DeviceEmployeeCode { get; set; }
}
