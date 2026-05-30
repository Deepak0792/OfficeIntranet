using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.Application.Interfaces.Services;

public interface IBiometricMappingService
{
    Task<IEnumerable<BiometricMappingResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default);
    Task<BiometricMappingResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default);
    Task<IEnumerable<BiometricMappingResponse>> GetByDeviceIdAsync(int deviceId, CancellationToken cancellationToken = default);
    Task<BiometricMappingResponse> AddAsync(int employeeId, AddBiometricMappingRequest request, CancellationToken cancellationToken = default);
    Task<BiometricMappingResponse> UpdateAsync(int employeeId, int id, UpdateBiometricMappingRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(int employeeId, int id, bool isActive, CancellationToken cancellationToken = default);
}
