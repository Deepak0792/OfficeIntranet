using SdxCore.Time.Domain.DTOs;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface ITimeZoneMasterService
{
    Task<IEnumerable<TimeZoneMasterDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<TimeZoneMasterDto?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<TimeZoneMasterDto> CreateAsync(CreateTimeZoneMasterDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateTimeZoneMasterDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(short id, CancellationToken cancellationToken = default);
}


