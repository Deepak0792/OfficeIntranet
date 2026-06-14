using SdxCore.Employee.Application.DTOs.EmployeeLocation.Request;
using SdxCore.Employee.Application.DTOs.EmployeeLocation.Response;

namespace SdxCore.Employee.Application.Abstractions.Services;

public interface IEmployeeLocationService
{
    Task<IEnumerable<EmployeeLocationResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeLocationResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
    Task<EmployeeLocationResponse> CreateAsync(Guid employeeId, CreateEmployeeLocationRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeLocationResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeLocationRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default);
    Task<bool> SetPrimaryAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
}
