using SdxCore.Employee.Application.DTOs.EmployeeDepartment.Request;
using SdxCore.Employee.Application.DTOs.EmployeeDepartment.Response;

namespace SdxCore.Employee.Application.Abstractions.Services;

public interface IEmployeeDepartmentService
{
    Task<IEnumerable<EmployeeDepartmentResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeDepartmentResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
    Task<EmployeeDepartmentResponse> AddAsync(Guid employeeId, CreateEmployeeDepartmentRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeDepartmentResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeDepartmentRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default);
    Task<bool> SetPrimaryAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
}
