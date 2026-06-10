using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.Application.Contracts.Services;

public interface ITeamService
{
    Task<IEnumerable<TeamResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<TeamResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<TeamResponse> CreateAsync(CreateTeamRequest request, CancellationToken cancellationToken = default);
    Task<TeamResponse> UpdateAsync(Guid id, UpdateTeamRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, bool isActive, CancellationToken cancellationToken = default);
}
