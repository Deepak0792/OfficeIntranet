using SdxCore.Employee.Application.DTOs.EmployeeLegalEntity.Request;
using SdxCore.Employee.Application.DTOs.EmployeeLegalEntity.Response;

namespace SdxCore.Employee.Application.Abstractions.Services;

public interface IEmployeeLegalEntityService
{
    Task<IEnumerable<EmployeeLegalEntityResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeLegalEntityResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
    Task<EmployeeLegalEntityResponse> AddAsync(Guid employeeId, CreateEmployeeLegalEntityRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeLegalEntityResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeLegalEntityRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default);
    Task<bool> SetPrimaryAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
}
