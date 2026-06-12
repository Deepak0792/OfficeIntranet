using SdxCore.Employee.Application.DTOs.EmployeeTeam.Request;
using SdxCore.Employee.Application.DTOs.EmployeeTeam.Response;

namespace SdxCore.Employee.Application.Abstractions.Services;

public interface IEmployeeTeamService
{
    Task<IEnumerable<EmployeeTeamResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeTeamResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
    Task<EmployeeTeamResponse> AddAsync(Guid employeeId, CreateEmployeeTeamRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeTeamResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeTeamRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default);
    Task<bool> SetPrimaryAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
}
