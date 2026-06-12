using SdxCore.Common.Models;
using SdxCore.Time.Application.DTOs.BiometricDevice.Request;
using SdxCore.Time.Application.DTOs.BiometricDevice.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;

namespace SdxCore.Time.Application.Abstractions.Services;

public interface IBiometricDeviceService
{
    Task<PagedResponse<IEnumerable<BiometricDeviceResponse>>> GetAllAsync(PaginationFilter filter, CancellationToken cancellationToken = default);
    Task<BiometricDeviceResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<BiometricDeviceResponse> CreateAsync(CreateBiometricDeviceRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateBiometricDeviceRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
    Task<bool> SyncDeviceAsync(Guid id, CancellationToken cancellationToken = default);
}

