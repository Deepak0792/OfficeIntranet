using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;

namespace SdxCore.Time.Application.Interfaces.Services;

public interface ILegalEntityService
{
    Task<IEnumerable<LegalEntityResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<LegalEntityResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<LegalEntityResponse> CreateAsync(CreateLegalEntityRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateLegalEntityRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


