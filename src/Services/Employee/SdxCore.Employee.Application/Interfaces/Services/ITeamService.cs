using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.Application.Interfaces.Services;

public interface ITeamService
{
    Task<IEnumerable<TeamResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<TeamResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<TeamResponse> CreateAsync(CreateTeamRequest request, CancellationToken cancellationToken = default);
    Task<TeamResponse> UpdateAsync(short id, UpdateTeamRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, bool isActive, CancellationToken cancellationToken = default);
}
