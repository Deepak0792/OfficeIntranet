using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.Application.Contracts.Services;

public interface IEmployeeTeamService
{
    Task<IEnumerable<EmployeeTeamResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeTeamResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
    Task<EmployeeTeamResponse> AddAsync(Guid employeeId, CreateEmployeeTeamRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeTeamResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeTeamRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default);
    Task<bool> SetPrimaryAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
}
