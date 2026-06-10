using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.Application.Contracts.Services;

public interface IEmployeeAddressService
{
    Task<IEnumerable<EmployeeAddressResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeAddressResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
    Task<EmployeeAddressResponse> AddAsync(Guid employeeId, CreateEmployeeAddressRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeAddressResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeAddressRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default);
    Task<bool> SetPrimaryAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
}
