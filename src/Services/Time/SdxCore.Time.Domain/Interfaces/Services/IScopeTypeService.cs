using SdxCore.Time.Domain.DTOs.Request;
using SdxCore.Time.Domain.DTOs.Response;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface IScopeTypeService
{
    Task<IEnumerable<ScopeTypeResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<ScopeTypeResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<ScopeTypeResponse> CreateAsync(CreateScopeTypeRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateScopeTypeRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


