using SdxCore.Employee.Application.DTOs.EmployeeContact.Request;
using SdxCore.Employee.Application.DTOs.EmployeeContact.Response;

namespace SdxCore.Employee.Application.Abstractions.Services;

public interface IEmployeeContactService
{
    Task<IEnumerable<EmployeeContactResponse>> GetByEmployeeIdAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<EmployeeContactResponse?> GetByIdAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
    Task<EmployeeContactResponse> AddAsync(Guid employeeId, CreateEmployeeContactRequest request, CancellationToken cancellationToken = default);
    Task<EmployeeContactResponse> UpdateAsync(Guid employeeId, Guid id, UpdateEmployeeContactRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid employeeId, Guid id, bool isActive, CancellationToken cancellationToken = default);
    Task<bool> SetPrimaryAsync(Guid employeeId, Guid id, CancellationToken cancellationToken = default);
}
