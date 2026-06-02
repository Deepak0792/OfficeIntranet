using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.Application.Interfaces.Services;

public interface IEmployeeDepartmentService
{
    Task<IEnumerable<EmployeeDepartmentResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeDepartmentResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default);
    Task<EmployeeDepartmentResponse> AddAsync(int employeeId, CreateEmployeeDepartmentRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeDepartmentResponse> UpdateAsync(int employeeId, int id, UpdateEmployeeDepartmentRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(int employeeId, int id, bool isActive, CancellationToken cancellationToken = default);
    Task<bool> SetPrimaryAsync(int employeeId, int id, CancellationToken cancellationToken = default);
}
