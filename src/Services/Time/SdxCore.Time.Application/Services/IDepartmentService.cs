using SdxCore.Time.Application.DTOs;
using SdxCore.Common.Models;
using System.Collections.Generic;

namespace SdxCore.Time.Application.Services;

public interface IDepartmentService
{
    Task<PagedResponse<IEnumerable<DepartmentDto>>> GetAllAsync(PaginationFilter filter, CancellationToken cancellationToken = default);
    Task<DepartmentDto?> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<DepartmentDto> CreateAsync(CreateDepartmentDto dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(long id, UpdateDepartmentDto dto, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(long id, CancellationToken cancellationToken = default);
}

