using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;

namespace SdxCore.Time.Application.Contracts.Services;

public interface IDesignationService
{
    Task<IEnumerable<DesignationResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<DesignationResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<DesignationResponse> CreateAsync(CreateDesignationRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateDesignationRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


