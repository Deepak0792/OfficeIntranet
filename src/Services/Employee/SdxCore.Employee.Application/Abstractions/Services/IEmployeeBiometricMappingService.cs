using SdxCore.Employee.Application.DTOs.EmployeeBiometricMapping.Request;
using SdxCore.Employee.Application.DTOs.EmployeeBiometricMapping.Response;

namespace SdxCore.Employee.Application.Abstractions.Services;

public interface IEmployeeBiometricMappingService
{
    Task<IEnumerable<EmployeeBiometricMappingResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeBiometricMappingResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<EmployeeBiometricMappingResponse>> GetByDeviceIdAsync(Guid deviceId, CancellationToken cancellationToken = default);
    Task<EmployeeBiometricMappingResponse> CreateAsync(Guid employeeId, CreateEmployeeBiometricMappingRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeBiometricMappingResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeBiometricMappingRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default);
}
