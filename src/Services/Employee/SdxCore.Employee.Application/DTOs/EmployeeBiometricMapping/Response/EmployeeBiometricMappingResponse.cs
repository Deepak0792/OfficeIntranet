namespace SdxCore.Employee.Application.DTOs.EmployeeBiometricMapping.Response;

public class EmployeeBiometricMappingResponse
{
    public Guid Id { get; set; }
    public Guid EmployeeId { get; set; }
    public Guid BiometricDeviceId { get; set; }
    public required string DeviceEmployeeCode { get; set; }
    public bool IsActive { get; set; }
}
