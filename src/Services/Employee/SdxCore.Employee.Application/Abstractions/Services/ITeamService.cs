using SdxCore.Employee.Application.DTOs.Team.Request;
using SdxCore.Employee.Application.DTOs.Team.Response;

namespace SdxCore.Employee.Application.Abstractions.Services;

public interface ITeamService
{
    Task<IEnumerable<TeamResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<TeamResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<TeamResponse> CreateAsync(CreateTeamRequest request, CancellationToken cancellationToken = default);
    Task<TeamResponse> UpdateAsync(Guid id, UpdateTeamRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, bool isActive, CancellationToken cancellationToken = default);
}
