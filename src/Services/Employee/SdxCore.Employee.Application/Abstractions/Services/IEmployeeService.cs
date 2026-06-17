using SdxCore.Common.Models;
using SdxCore.Employee.Application.DTOs.Employee.Request;
using SdxCore.Employee.Application.DTOs.Employee.Response;

namespace SdxCore.Employee.Application.Abstractions.Services;

public interface IEmployeeService
{
    Task<PagedResponse<IEnumerable<EmployeeSummaryResponse>>> GetAllAsync(PaginationFilter filter, Guid? departmentId,
        Guid? locationId, Guid? legalEntityId, string? employmentType, bool? isActive, CancellationToken cancellationToken = default);
    Task<EmployeeSummaryResponse?> GetFullProfileAsync(Guid id, CancellationToken cancellationToken = default);
    Task<EmployeeResponse?> GetByCodeAsync(string employeeCode, CancellationToken cancellationToken = default);
    Task<EmployeeResponse?> GetByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<PagedResponse<IEnumerable<EmployeeSummaryResponse>>> SearchAsync(string query, PaginationFilter filter, CancellationToken cancellationToken = default);
    Task<EmployeeSummaryResponse?> GetSummaryAsync(Guid id, CancellationToken cancellationToken = default);
    Task<EmployeeResponse> CreateAsync(CreateEmployeeRequest request, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(Guid id, UpdateEmployeeRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, UpdateEmployeeStatusRequest request, CancellationToken cancellationToken = default);
    Task<bool> UpdatePhotoAsync(Guid id, UpdateEmployeePhotoRequest request, CancellationToken cancellationToken = default);
    Task<bool> UpdateAboutAsync(Guid id, UpdateEmployeeAboutRequest request, CancellationToken cancellationToken = default);
    /// <summary>
    /// Returns employees who hold any of the given designations,
    /// optionally restricted to a specific scope (dept/office/entity/team).
    /// Used by the Workflow engine's approver resolver for DESIGNATION type rules.
    /// </summary>
    Task<IEnumerable<EmployeesByDesignationResponse>> GetEmployeesByDesignationInScopeAsync(
        List<Guid> designationIds,
        string? scopeCode,
        Guid? scopeReferenceId,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<EmployeeSummaryResponse>> GetAllEmployeesAsync(bool isActive = true, CancellationToken cancellationToken = default);
}
