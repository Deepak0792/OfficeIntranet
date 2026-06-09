using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;

namespace SdxCore.Time.Application.Contracts.Services;

public interface IScopeTypeService
{
    Task<IEnumerable<ScopeTypeResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<ScopeTypeResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<ScopeTypeResponse> CreateAsync(CreateScopeTypeRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateScopeTypeRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


