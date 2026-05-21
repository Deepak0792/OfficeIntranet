using SdxCore.Time.Domain.DTOs;
using System.Collections.Generic;
using SdxCore.Common.Models;
using System.Threading;
using System.Threading.Tasks;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface IDesignationService
{
    Task<IEnumerable<DesignationDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<DesignationDto?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<DesignationDto> CreateAsync(CreateDesignationDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateDesignationDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(short id, CancellationToken cancellationToken = default);
}


