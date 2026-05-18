using SdxCore.Time.Application.DTOs;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Application.Services;

public interface ILegalEntityService
{
    Task<IEnumerable<LegalEntityDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<LegalEntityDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<LegalEntityDto> CreateAsync(CreateLegalEntityDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(long id, UpdateLegalEntityDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default);
}


