using SdxCore.Time.Domain.DTOs;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface ILegalEntityService
{
    Task<IEnumerable<LegalEntityDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<LegalEntityDto?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<LegalEntityDto> CreateAsync(CreateLegalEntityDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateLegalEntityDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(short id, CancellationToken cancellationToken = default);
}


