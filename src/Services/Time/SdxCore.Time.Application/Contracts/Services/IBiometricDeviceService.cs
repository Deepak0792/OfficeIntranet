using SdxCore.Common.Models;
using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;

namespace SdxCore.Time.Application.Contracts.Services;

public interface IBiometricDeviceService
{
    Task<PagedResponse<IEnumerable<BiometricDeviceResponse>>> GetAllAsync(PaginationFilter filter, CancellationToken cancellationToken = default);
    Task<BiometricDeviceResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<BiometricDeviceResponse> CreateAsync(CreateBiometricDeviceRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(int id, UpdateBiometricDeviceRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(int id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
    Task<bool> SyncDeviceAsync(int id, System.Threading.CancellationToken cancellationToken = default);
}

