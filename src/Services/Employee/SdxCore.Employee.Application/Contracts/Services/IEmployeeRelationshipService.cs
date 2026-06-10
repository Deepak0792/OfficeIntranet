using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.Application.Contracts.Services;

public interface IEmployeeRelationshipService
{
    Task<IEnumerable<EmployeeRelationshipResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeRelationshipResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<EmployeeRelationshipResponse>> GetDirectReportsAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeRelationshipResponse?> GetManagerAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeRelationshipResponse> AddAsync(Guid employeeId, CreateEmployeeRelationshipRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeRelationshipResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeRelationshipRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default);
    Task<bool> SetPrimaryAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
}
