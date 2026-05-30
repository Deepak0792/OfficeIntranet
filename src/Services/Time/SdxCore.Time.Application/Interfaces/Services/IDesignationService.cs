using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;

namespace SdxCore.Time.Application.Interfaces.Services;

public interface IDesignationService
{
    Task<IEnumerable<DesignationResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<DesignationResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<DesignationResponse> CreateAsync(CreateDesignationRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateDesignationRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


