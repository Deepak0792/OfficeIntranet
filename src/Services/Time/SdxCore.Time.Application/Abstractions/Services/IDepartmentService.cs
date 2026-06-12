using SdxCore.Time.Application.DTOs.Department.Request;
using SdxCore.Time.Application.DTOs.Department.Response;
using SdxCore.Time.Application.DTOs.Shared.Request;

namespace SdxCore.Time.Application.Abstractions.Services;

public interface IDepartmentService
{
    Task<IEnumerable<DepartmentResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<DepartmentResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<DepartmentResponse> CreateAsync(CreateDepartmentRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateDepartmentRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
    Task<IEnumerable<DepartmentResponse>> GetTreeAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<DepartmentResponse>> GetChildrenAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<DepartmentResponse>> GetAncestorsAsync(Guid id, CancellationToken cancellationToken = default);
    Task<bool> UpdateParentAsync(Guid id, UpdateParentRequest request, CancellationToken cancellationToken = default);
}


