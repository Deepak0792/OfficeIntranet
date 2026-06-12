using SdxCore.Time.Application.DTOs.LegalEntity.Request;
using SdxCore.Time.Application.DTOs.LegalEntity.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;

namespace SdxCore.Time.Application.Abstractions.Services;

public interface ILegalEntityService
{
    Task<IEnumerable<LegalEntityResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<LegalEntityResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<LegalEntityResponse> CreateAsync(CreateLegalEntityRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateLegalEntityRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


