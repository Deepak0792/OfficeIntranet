using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.Application.Interfaces.Services;

public interface IEmployeeBiometricMappingService
{
    Task<IEnumerable<EmployeeBiometricMappingResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeBiometricMappingResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default);
    Task<IEnumerable<EmployeeBiometricMappingResponse>> GetByDeviceIdAsync(int deviceId, CancellationToken cancellationToken = default);
    Task<EmployeeBiometricMappingResponse> AddAsync(int employeeId, CreateEmployeeBiometricMappingRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeBiometricMappingResponse> UpdateAsync(int employeeId, int id, UpdateEmployeeBiometricMappingRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(int employeeId, int id, bool isActive, CancellationToken cancellationToken = default);
}
