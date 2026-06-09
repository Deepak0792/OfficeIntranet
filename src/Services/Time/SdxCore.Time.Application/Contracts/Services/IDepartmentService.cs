using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;

namespace SdxCore.Time.Application.Contracts.Services;

public interface IDepartmentService
{
    Task<IEnumerable<DepartmentResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<DepartmentResponse?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<DepartmentResponse> CreateAsync(CreateDepartmentRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateDepartmentRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
    Task<System.Collections.Generic.IEnumerable<DepartmentResponse>> GetTreeAsync(System.Threading.CancellationToken cancellationToken = default);
    Task<System.Collections.Generic.IEnumerable<DepartmentResponse>> GetChildrenAsync(Guid id, System.Threading.CancellationToken cancellationToken = default);
    Task<System.Collections.Generic.IEnumerable<DepartmentResponse>> GetAncestorsAsync(Guid id, System.Threading.CancellationToken cancellationToken = default);
    Task<bool> UpdateParentAsync(Guid id, UpdateParentRequest request, System.Threading.CancellationToken cancellationToken = default);
}


