using SdxCore.Time.Application.DTOs;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Application.Services;

public interface IRegionService
{
    Task<IEnumerable<RegionDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<RegionDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<RegionDto> CreateAsync(CreateRegionDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(long id, UpdateRegionDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default);
}


