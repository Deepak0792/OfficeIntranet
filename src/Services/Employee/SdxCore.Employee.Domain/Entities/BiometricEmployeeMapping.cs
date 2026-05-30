namespace SdxCore.Employee.Domain.Entities;

public class BiometricEmployeeMapping : BaseEntity
{
    public int Id { get; set; }
    public int EmployeeId { get; set; }
    public int BiometricDeviceId { get; set; }
    public required string DeviceEmployeeCode { get; set; }

    public Employee Employee { get; set; } = null!;
}
