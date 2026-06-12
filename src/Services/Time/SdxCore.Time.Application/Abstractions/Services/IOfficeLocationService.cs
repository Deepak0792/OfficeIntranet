using SdxCore.Time.Application.DTOs.OfficeLocation.Request;
using SdxCore.Time.Application.DTOs.OfficeLocation.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;

namespace SdxCore.Time.Application.Abstractions.Services;

public interface IOfficeLocationService
{
    Task<IEnumerable<OfficeLocationResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<OfficeLocationResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<OfficeLocationResponse> CreateAsync(CreateOfficeLocationRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateOfficeLocationRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


