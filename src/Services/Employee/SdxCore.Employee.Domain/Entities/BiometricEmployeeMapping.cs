namespace SdxCore.Employee.Domain.Entities;

public class BiometricEmployeeMapping : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public int BiometricDeviceId { get; set; }
    public string DeviceEmployeeCode { get; set; } = string.Empty;

    public Employee? Employee { get; set; }
}
