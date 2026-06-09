using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;

namespace SdxCore.Time.Application.Contracts.Services;

public interface IRegionService
{
    Task<IEnumerable<RegionResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<RegionResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<RegionResponse> CreateAsync(CreateRegionRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateRegionRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
    Task<IEnumerable<RegionResponse>> GetByCountryIdAsync(Guid countryId, CancellationToken cancellationToken = default);
    Task<IEnumerable<RegionResponse>> GetTreeAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<RegionResponse>> GetChildrenAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<RegionResponse>> GetAncestorsAsync(Guid id, CancellationToken cancellationToken = default);
    Task<bool> UpdateParentAsync(Guid id, UpdateParentRequest request, CancellationToken cancellationToken = default);
}


