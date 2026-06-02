using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;

namespace SdxCore.Time.Application.Contracts.Services;

public interface IGeoFenceService
{
    Task<IEnumerable<GeoFenceResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<GeoFenceResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<GeoFenceResponse> CreateAsync(CreateGeoFenceRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateGeoFenceRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
    Task<GeoFenceResponse?> CheckGeoFenceAsync(GeoFenceCheckRequest request, System.Threading.CancellationToken cancellationToken = default);
}


