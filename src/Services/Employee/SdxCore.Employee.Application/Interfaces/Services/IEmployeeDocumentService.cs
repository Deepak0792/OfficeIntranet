using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.Application.Interfaces.Services;

public interface IEmployeeDocumentService
{
    Task<IEnumerable<EmployeeDocumentResponse>> GetByEmployeeIdAsync(int employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeDocumentResponse?> GetByIdAsync(int employeeId, int id, CancellationToken cancellationToken = default);
    Task<IEnumerable<EmployeeDocumentResponse>> GetExpiringAsync(int employeeId, int days, CancellationToken cancellationToken = default);
    Task<EmployeeDocumentResponse> AddAsync(int employeeId, AddEmployeeDocumentRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeDocumentResponse> UpdateAsync(int employeeId, int id, UpdateEmployeeDocumentRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(int employeeId, int id, bool isActive, CancellationToken cancellationToken = default);
}
