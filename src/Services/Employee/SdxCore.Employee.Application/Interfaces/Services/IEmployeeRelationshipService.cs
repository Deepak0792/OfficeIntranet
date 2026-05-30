using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.Application.Interfaces.Services;

public interface IEmployeeRelationshipService
{
    Task<IEnumerable<EmployeeRelationshipResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeRelationshipResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default);
    Task<IEnumerable<EmployeeRelationshipResponse>> GetDirectReportsAsync(int employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeRelationshipResponse?> GetManagerAsync(int employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeRelationshipResponse> AddAsync(int employeeId, AddEmployeeRelationshipRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeRelationshipResponse> UpdateAsync(int employeeId, int id, UpdateEmployeeRelationshipRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(int employeeId, int id, bool isActive, CancellationToken cancellationToken = default);
    Task<bool> SetPrimaryAsync(int employeeId, int id, CancellationToken cancellationToken = default);
}
