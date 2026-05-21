using SdxCore.Time.Domain.DTOs;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface IBiometricDeviceService
{
    Task<PagedResponse<IEnumerable<BiometricDeviceDto>>> GetAllAsync(PaginationFilter filter, CancellationToken cancellationToken = default);
    Task<BiometricDeviceDto?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<BiometricDeviceDto> CreateAsync(CreateBiometricDeviceDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(int id, UpdateBiometricDeviceDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(int id, CancellationToken cancellationToken = default);
}

