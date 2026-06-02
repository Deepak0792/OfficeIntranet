namespace SdxCore.Employee.Application.DTOs.Response;

public class EmployeeBiometricMappingResponse
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public int BiometricDeviceId { get; set; }
    public required string DeviceEmployeeCode { get; set; }
    public bool IsActive { get; set; }
}
