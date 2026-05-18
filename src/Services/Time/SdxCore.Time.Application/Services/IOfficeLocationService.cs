using SdxCore.Time.Application.DTOs;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Application.Services;

public interface IOfficeLocationService
{
    Task<IEnumerable<OfficeLocationDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<OfficeLocationDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<OfficeLocationDto> CreateAsync(CreateOfficeLocationDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(long id, UpdateOfficeLocationDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default);
}


