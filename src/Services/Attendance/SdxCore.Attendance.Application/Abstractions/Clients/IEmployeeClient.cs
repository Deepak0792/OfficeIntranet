using SdxCore.Attendance.Application.DTOs.Employee;

namespace SdxCore.Attendance.Application.Abstractions.Clients;

public interface IEmployeeClient
{
    Task<IReadOnlyList<EmployeeSummaryResponse>> GetEmployeesAsync(bool isActive = true, CancellationToken cancellationToken = default);
    Task<EmployeeSummaryResponse?> GetEmployeeSummaryByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<EmployeesByDesignationResponse>> GetEmployeesByDesignationInScopeAsync(IEnumerable<Guid> designationIds, string? scopeCode, Guid? scopeReferenceId, CancellationToken cancellationToken = default);
}
