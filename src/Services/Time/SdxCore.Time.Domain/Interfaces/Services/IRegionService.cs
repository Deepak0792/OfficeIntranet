using SdxCore.Time.Domain.DTOs;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface IRegionService
{
    Task<IEnumerable<RegionDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<RegionDto?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<RegionDto> CreateAsync(CreateRegionDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateRegionDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(short id, CancellationToken cancellationToken = default);
}


