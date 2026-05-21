using SdxCore.Time.Domain.DTOs.Request;
using SdxCore.Time.Domain.DTOs.Response;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface IRegionService
{
    Task<IEnumerable<RegionResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<RegionResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<RegionResponse> CreateAsync(CreateRegionRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateRegionRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
    Task<System.Collections.Generic.IEnumerable<RegionResponse>> GetByCountryIdAsync(short countryId, System.Threading.CancellationToken cancellationToken = default);
    Task<System.Collections.Generic.IEnumerable<RegionResponse>> GetTreeAsync(System.Threading.CancellationToken cancellationToken = default);
    Task<System.Collections.Generic.IEnumerable<RegionResponse>> GetChildrenAsync(short id, System.Threading.CancellationToken cancellationToken = default);
    Task<System.Collections.Generic.IEnumerable<RegionResponse>> GetAncestorsAsync(short id, System.Threading.CancellationToken cancellationToken = default);
    Task<bool> UpdateParentAsync(short id, UpdateParentRequest request, System.Threading.CancellationToken cancellationToken = default);
}


