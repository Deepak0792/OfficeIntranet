using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.Application.Interfaces.Services;

public interface IEmployeeAddressService
{
    Task<IEnumerable<EmployeeAddressResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeAddressResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default);
    Task<EmployeeAddressResponse> AddAsync(int employeeId, CreateEmployeeAddressRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeAddressResponse> UpdateAsync(int employeeId, int id, UpdateEmployeeAddressRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(int employeeId, int id, bool isActive, CancellationToken cancellationToken = default);
    Task<bool> SetPrimaryAsync(int employeeId, int id, CancellationToken cancellationToken = default);
}
