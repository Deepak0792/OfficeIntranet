using SdxCore.Time.Application.DTOs.DocumentType.Request;
using SdxCore.Time.Application.DTOs.DocumentType.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;

namespace SdxCore.Time.Application.Abstractions.Services;

public interface IDocumentTypeService
{
    Task<IEnumerable<DocumentTypeResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<DocumentTypeResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<DocumentTypeResponse> CreateAsync(CreateDocumentTypeRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateDocumentTypeRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


