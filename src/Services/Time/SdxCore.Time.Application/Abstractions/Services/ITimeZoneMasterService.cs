using SdxCore.Time.Application.DTOs.Shared.Request;
using SdxCore.Time.Application.DTOs.TimeZoneMaster.Request;
using SdxCore.Time.Application.DTOs.TimeZoneMaster.Response;

namespace SdxCore.Time.Application.Abstractions.Services;

public interface ITimeZoneMasterService
{
    Task<IEnumerable<TimeZoneMasterResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<TimeZoneMasterResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<TimeZoneMasterResponse> CreateAsync(CreateTimeZoneMasterRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateTimeZoneMasterRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


