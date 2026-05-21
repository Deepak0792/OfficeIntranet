using SdxCore.Time.Domain.DTOs.Request;
using SdxCore.Time.Domain.DTOs.Response;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface ITimeZoneMasterService
{
    Task<IEnumerable<TimeZoneMasterResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<TimeZoneMasterResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<TimeZoneMasterResponse> CreateAsync(CreateTimeZoneMasterRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateTimeZoneMasterRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


