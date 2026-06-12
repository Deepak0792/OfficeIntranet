using SdxCore.Workflow.Application.DTOs.Employee;
using System.Threading;

namespace SdxCore.Workflow.Application.Abstractions.Services;

public interface IEmployeeQueryService
{
    Task<EmployeeSummaryResponse?> GetReportingManagerAsync(Guid employeeId, CancellationToken cancellationToken = default!);
    Task<EmployeeSummaryResponse?> GetEmployeeByIdAsync(Guid employeeId, CancellationToken cancellationToken = default!);
    Task<IEnumerable<EmployeesByDesignationResponse>> GetEmployeesByDesignationInScopeAsync(
        IEnumerable<Guid> designationIds,
        string? scopeCode,
        Guid? scopeReferenceId);
    //Task<IEnumerable<EmployeeSummaryResponse>> GetEmployeesByRoleInScopeAsync(
    //    Guid approverRuleId, Guid? scopeTypeId, Guid? scopeReferenceId);
    Task<Guid?> GetScopeReferenceIdAsync(Guid employeeId, string? scopeCode, CancellationToken cancellationToken = default!);
}
