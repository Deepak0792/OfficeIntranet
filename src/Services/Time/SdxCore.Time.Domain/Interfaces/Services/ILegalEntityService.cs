using SdxCore.Time.Domain.DTOs.Request;
using SdxCore.Time.Domain.DTOs.Response;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface ILegalEntityService
{
    Task<IEnumerable<LegalEntityResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<LegalEntityResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<LegalEntityResponse> CreateAsync(CreateLegalEntityRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateLegalEntityRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


