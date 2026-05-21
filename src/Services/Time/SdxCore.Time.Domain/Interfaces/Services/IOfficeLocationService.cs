using SdxCore.Time.Domain.DTOs;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface IOfficeLocationService
{
    Task<IEnumerable<OfficeLocationDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<OfficeLocationDto?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<OfficeLocationDto> CreateAsync(CreateOfficeLocationDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateOfficeLocationDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(short id, CancellationToken cancellationToken = default);
}


