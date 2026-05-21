using SdxCore.Time.Domain.DTOs.Request;
using SdxCore.Time.Domain.DTOs.Response;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface IDocumentTypeService
{
    Task<IEnumerable<DocumentTypeResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<DocumentTypeResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<DocumentTypeResponse> CreateAsync(CreateDocumentTypeRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateDocumentTypeRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


