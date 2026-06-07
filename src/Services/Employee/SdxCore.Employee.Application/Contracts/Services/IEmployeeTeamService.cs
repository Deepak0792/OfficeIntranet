using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.Application.Contracts.Services;

public interface IEmployeeTeamService
{
    Task<IEnumerable<EmployeeTeamResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeTeamResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default);
    Task<EmployeeTeamResponse> AddAsync(int employeeId, CreateEmployeeTeamRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeTeamResponse> UpdateAsync(int employeeId, int id, UpdateEmployeeTeamRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(int employeeId, int id, bool isActive, CancellationToken cancellationToken = default);
    Task<bool> SetPrimaryAsync(int employeeId, int id, CancellationToken cancellationToken = default);
}
