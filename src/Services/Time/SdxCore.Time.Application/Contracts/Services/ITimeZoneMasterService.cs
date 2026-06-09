using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;

namespace SdxCore.Time.Application.Contracts.Services;

public interface ITimeZoneMasterService
{
    Task<IEnumerable<TimeZoneMasterResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<TimeZoneMasterResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<TimeZoneMasterResponse> CreateAsync(CreateTimeZoneMasterRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateTimeZoneMasterRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


