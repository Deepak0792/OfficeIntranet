using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;
public class EmployeeBiometricMapping : BaseAuditEntity<int>
{
    public int EmployeeId { get; set; }
    public int BiometricDeviceId { get; set; }
    public required string DeviceEmployeeCode { get; set; }

    public Employee Employee { get; set; } = null!;
}
