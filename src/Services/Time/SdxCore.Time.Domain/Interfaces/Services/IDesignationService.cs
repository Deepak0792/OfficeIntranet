using SdxCore.Time.Domain.DTOs.Request;
using SdxCore.Time.Domain.DTOs.Response;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface IDesignationService
{
    Task<IEnumerable<DesignationResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<DesignationResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<DesignationResponse> CreateAsync(CreateDesignationRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateDesignationRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


