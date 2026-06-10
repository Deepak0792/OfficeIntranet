using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.Application.Contracts.Services;

public interface IEmployeeDocumentService
{
    Task<IEnumerable<EmployeeDocumentResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeDocumentResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<EmployeeDocumentResponse>> GetExpiringAsync(Guid employeeId, int days, CancellationToken cancellationToken = default);
    Task<EmployeeDocumentResponse> AddAsync(Guid employeeId, CreateEmployeeDocumentRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeDocumentResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeDocumentRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default);
}
