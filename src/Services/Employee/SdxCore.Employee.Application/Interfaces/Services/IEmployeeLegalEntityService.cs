using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.Application.Interfaces.Services;

public interface IEmployeeLegalEntityService
{
    Task<IEnumerable<EmployeeLegalEntityResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeLegalEntityResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default);
    Task<EmployeeLegalEntityResponse> AddAsync(int employeeId, AddEmployeeLegalEntityRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeLegalEntityResponse> UpdateAsync(int employeeId, int id, UpdateEmployeeLegalEntityRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(int employeeId, int id, bool isActive, CancellationToken cancellationToken = default);
    Task<bool> SetPrimaryAsync(int employeeId, int id, CancellationToken cancellationToken = default);
}
