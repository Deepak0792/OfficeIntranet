using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;

namespace SdxCore.Time.Application.Contracts.Services;

public interface IScopeTypeService
{
    Task<IEnumerable<ScopeTypeResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<ScopeTypeResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<ScopeTypeResponse> CreateAsync(CreateScopeTypeRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateScopeTypeRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


