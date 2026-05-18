using SdxCore.Time.Application.DTOs;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Application.Services;

public interface IBiometricDeviceService
{
    Task<PagedResponse<IEnumerable<BiometricDeviceDto>>> GetAllAsync(PaginationFilter filter, CancellationToken cancellationToken = default);
    Task<BiometricDeviceDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<BiometricDeviceDto> CreateAsync(CreateBiometricDeviceDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(long id, UpdateBiometricDeviceDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default);
}

