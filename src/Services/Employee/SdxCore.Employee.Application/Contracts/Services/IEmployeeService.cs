using SdxCore.Common.Models;
using SdxCore.Employee.Application.DTOs.Request;
using SdxCore.Employee.Application.DTOs.Response;

namespace SdxCore.Employee.Application.Contracts.Services;

public interface IEmployeeService
{
    Task<PagedResponse<IEnumerable<EmployeeSummaryResponse>>> GetAllAsync(PaginationFilter filter, int? departmentId, int? locationId, int? legalEntityId, string? employmentType, bool? isActive, CancellationToken cancellationToken = default);
    Task<EmployeeSummaryResponse?> GetFullProfileAsync(int id, CancellationToken cancellationToken = default);
    Task<EmployeeResponse?> GetByCodeAsync(string employeeCode, CancellationToken cancellationToken = default);
    Task<EmployeeResponse?> GetByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<PagedResponse<IEnumerable<EmployeeSummaryResponse>>> SearchAsync(string query, PaginationFilter filter, CancellationToken cancellationToken = default);
    Task<EmployeeSummaryResponse?> GetSummaryAsync(int id, CancellationToken cancellationToken = default);
    Task<EmployeeResponse> CreateAsync(CreateEmployeeRequest request, CancellationToken cancellationToken = default);
    Task<bool> UpdateAsync(int id, UpdateEmployeeRequest request, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(int id, UpdateEmployeeStatusRequest request, CancellationToken cancellationToken = default);
    Task<bool> UpdatePhotoAsync(int id, UpdateEmployeePhotoRequest request, CancellationToken cancellationToken = default);
    Task<bool> UpdateAboutAsync(int id, UpdateEmployeeAboutRequest request, CancellationToken cancellationToken = default);    
    /// <summary>
    /// Returns employees who hold any of the given designations,
    /// optionally restricted to a specific scope (dept/office/entity/team).
    /// Used by the Workflow engine's approver resolver for DESIGNATION type rules.
    /// </summary>
    Task<IEnumerable<EmployeesByDesignationResponse>> GetEmployeesByDesignationInScopeAsync(
        List<short> designationIds,
        short? scopeTypeId,
        int? scopeReferenceId,
        CancellationToken cancellationToken = default);
}
