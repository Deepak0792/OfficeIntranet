using SdxCore.Time.Application.DTOs.ScopeType.Request;
using SdxCore.Time.Application.DTOs.ScopeType.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;

namespace SdxCore.Time.Application.Abstractions.Services;

public interface IScopeTypeService
{
    Task<IEnumerable<ScopeTypeResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<ScopeTypeResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<ScopeTypeResponse> CreateAsync(CreateScopeTypeRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateScopeTypeRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


