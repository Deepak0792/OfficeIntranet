using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;

namespace SdxCore.Time.Application.Contracts.Services;

public interface ILegalEntityService
{
    Task<IEnumerable<LegalEntityResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<LegalEntityResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<LegalEntityResponse> CreateAsync(CreateLegalEntityRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateLegalEntityRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


