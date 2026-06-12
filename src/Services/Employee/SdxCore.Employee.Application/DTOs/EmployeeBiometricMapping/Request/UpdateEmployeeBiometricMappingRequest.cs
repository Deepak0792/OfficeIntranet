namespace SdxCore.Employee.Application.DTOs.EmployeeBiometricMapping.Request;

public class UpdateEmployeeBiometricMappingRequest
{
    /// <summary>Cross-schema FK to time.BiometricDevice. Allows reassigning the device.</summary>
    public Guid BiometricDeviceId { get; set; }
    public required string DeviceEmployeeCode { get; set; }
}
