using SdxCore.Time.Application.DTOs.Request;
using SdxCore.Time.Application.DTOs.Response;

namespace SdxCore.Time.Application.Interfaces.Services;

public interface IDepartmentService
{
    Task<IEnumerable<DepartmentResponse>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<DepartmentResponse?> GetByIdAsync(short id, CancellationToken cancellationToken = default);
    Task<DepartmentResponse> CreateAsync(CreateDepartmentRequest dto, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(short id, UpdateDepartmentRequest dto, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, ToggleStatusRequest request, CancellationToken cancellationToken = default);
    Task<System.Collections.Generic.IEnumerable<DepartmentResponse>> GetTreeAsync(System.Threading.CancellationToken cancellationToken = default);
    Task<System.Collections.Generic.IEnumerable<DepartmentResponse>> GetChildrenAsync(short id, System.Threading.CancellationToken cancellationToken = default);
    Task<System.Collections.Generic.IEnumerable<DepartmentResponse>> GetAncestorsAsync(short id, System.Threading.CancellationToken cancellationToken = default);
    Task<bool> UpdateParentAsync(short id, UpdateParentRequest request, System.Threading.CancellationToken cancellationToken = default);
}


