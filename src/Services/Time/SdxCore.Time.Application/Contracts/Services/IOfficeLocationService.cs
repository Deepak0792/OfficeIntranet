using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;

namespace SdxCore.Time.Application.Contracts.Services;

public interface IOfficeLocationService
{
    Task<IEnumerable<OfficeLocationResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<OfficeLocationResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<OfficeLocationResponse> CreateAsync(CreateOfficeLocationRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateOfficeLocationRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


