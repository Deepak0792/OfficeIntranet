using SdxCore.Time.Application.DTOs;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Application.Services;

public interface ITimeZoneMasterService
{
    Task<PagedResponse<IEnumerable<TimeZoneMasterDto>>> GetAllAsync(PaginationFilter filter, CancellationToken cancellationToken = default);
    Task<TimeZoneMasterDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<TimeZoneMasterDto> CreateAsync(CreateTimeZoneMasterDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(long id, UpdateTimeZoneMasterDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default);
}

