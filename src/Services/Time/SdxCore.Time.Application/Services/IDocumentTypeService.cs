using SdxCore.Time.Application.DTOs;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Application.Services;

public interface IDocumentTypeService
{
    Task<IEnumerable<DocumentTypeDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<DocumentTypeDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<DocumentTypeDto> CreateAsync(CreateDocumentTypeDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(long id, UpdateDocumentTypeDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default);
}


