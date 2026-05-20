using SdxCore.Time.Domain.DTOs;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface IGeoFenceService
{
    Task<IEnumerable<GeoFenceDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<GeoFenceDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<GeoFenceDto> CreateAsync(CreateGeoFenceDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(long id, UpdateGeoFenceDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default);
}


