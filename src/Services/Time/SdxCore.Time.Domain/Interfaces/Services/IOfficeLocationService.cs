using SdxCore.Time.Domain.DTOs.Request;
using SdxCore.Time.Domain.DTOs.Response;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface IOfficeLocationService
{
    Task<IEnumerable<OfficeLocationResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<OfficeLocationResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<OfficeLocationResponse> CreateAsync(CreateOfficeLocationRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateOfficeLocationRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
}


