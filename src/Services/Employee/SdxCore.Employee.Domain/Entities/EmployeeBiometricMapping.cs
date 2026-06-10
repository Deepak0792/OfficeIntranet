using SdxCore.SharedKernel.Entities;

namespace SdxCore.Employee.Domain.Entities;
public class EmployeeBiometricMapping : BaseAuditEntity<Guid>
{
    public Guid EmployeeId { get; set; }
    public Guid BiometricDeviceId { get; set; }
    public required string DeviceEmployeeCode { get; set; }
    public bool IsActive { get; set; } = true;

    public Employee Employee { get; set; } = null!;
}
