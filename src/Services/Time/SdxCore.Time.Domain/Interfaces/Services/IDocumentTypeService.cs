using SdxCore.Time.Domain.DTOs;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface IDocumentTypeService
{
    Task<IEnumerable<DocumentTypeDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<DocumentTypeDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<DocumentTypeDto> CreateAsync(CreateDocumentTypeDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(long id, UpdateDocumentTypeDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default);
}


