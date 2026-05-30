namespace SdxCore.Employee.Application.DTOs.Response;

public class BiometricMappingResponse
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public int BiometricDeviceId { get; set; }
    public required string DeviceEmployeeCode { get; set; }
    public bool IsActive { get; set; }
}
