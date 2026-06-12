using SdxCore.Time.Application.DTOs.GeoFence.Request;
using SdxCore.Time.Application.DTOs.GeoFence.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;

namespace SdxCore.Time.Application.Abstractions.Services;

public interface IGeoFenceService
{
    Task<IEnumerable<GeoFenceResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<GeoFenceResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<GeoFenceResponse> CreateAsync(CreateGeoFenceRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateGeoFenceRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
    Task<GeoFenceResponse?> CheckGeoFenceAsync(GeoFenceCheckRequest request, CancellationToken cancellationToken = default);
}


