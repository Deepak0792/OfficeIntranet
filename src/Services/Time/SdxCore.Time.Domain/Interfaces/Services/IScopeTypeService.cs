using SdxCore.Time.Domain.DTOs;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface IScopeTypeService
{
    Task<IEnumerable<ScopeTypeDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<ScopeTypeDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<ScopeTypeDto> CreateAsync(CreateScopeTypeDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(long id, UpdateScopeTypeDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default);
}


