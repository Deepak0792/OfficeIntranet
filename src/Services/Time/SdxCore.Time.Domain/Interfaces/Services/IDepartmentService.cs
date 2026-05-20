using SdxCore.Time.Domain.DTOs;
using SdxCore.Common.Models;
using System.Collections.Generic;

namespace SdxCore.Time.Domain.Interfaces.Services;

public interface IDepartmentService
{
    Task<IEnumerable<DepartmentDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<DepartmentDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<DepartmentDto> CreateAsync(CreateDepartmentDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(long id, UpdateDepartmentDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default);
}


