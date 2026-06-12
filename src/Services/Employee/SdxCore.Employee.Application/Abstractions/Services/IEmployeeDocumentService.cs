using SdxCore.Employee.Application.DTOs.EmployeeDocument.Request;
using SdxCore.Employee.Application.DTOs.EmployeeDocument.Response;

namespace SdxCore.Employee.Application.Abstractions.Services;

public interface IEmployeeDocumentService
{
    Task<IEnumerable<EmployeeDocumentResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeDocumentResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<EmployeeDocumentResponse>> GetExpiringAsync(Guid employeeId, int days, CancellationToken cancellationToken = default);
    Task<EmployeeDocumentResponse> AddAsync(Guid employeeId, CreateEmployeeDocumentRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeDocumentResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeDocumentRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default);
}
