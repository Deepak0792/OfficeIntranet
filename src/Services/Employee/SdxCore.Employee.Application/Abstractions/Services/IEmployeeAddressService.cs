using SdxCore.Employee.Application.DTOs.EmployeeAddress.Request;
using SdxCore.Employee.Application.DTOs.EmployeeAddress.Response;

namespace SdxCore.Employee.Application.Abstractions.Services;

public interface IEmployeeAddressService
{
    Task<IEnumerable<EmployeeAddressResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeAddressResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
    Task<EmployeeAddressResponse> CreateAsync(Guid employeeId, CreateEmployeeAddressRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeAddressResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeAddressRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default);
    Task<bool> SetPrimaryAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
}
