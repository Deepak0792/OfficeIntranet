using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;

namespace SdxCore.Time.Application.Contracts.Services;

public interface IOfficeLocationService
{
    Task<IEnumerable<OfficeLocationResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<OfficeLocationResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<OfficeLocationResponse> CreateAsync(CreateOfficeLocationRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateOfficeLocationRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


