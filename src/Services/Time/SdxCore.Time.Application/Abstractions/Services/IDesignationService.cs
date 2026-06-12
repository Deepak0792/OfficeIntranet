using SdxCore.Time.Application.DTOs.Designation.Request;
using SdxCore.Time.Application.DTOs.Designation.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;

namespace SdxCore.Time.Application.Abstractions.Services;

public interface IDesignationService
{
    Task<IEnumerable<DesignationResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<DesignationResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<DesignationResponse> CreateAsync(CreateDesignationRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateDesignationRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


