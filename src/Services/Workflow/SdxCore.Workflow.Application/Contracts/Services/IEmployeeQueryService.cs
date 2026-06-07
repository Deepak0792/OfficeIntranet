using SdxCore.Workflow.Application.DTOs.Response;
using System.Threading;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IEmployeeQueryService
{
    Task<EmployeeSummaryResponse?> GetReportingManagerAsync(int employeeId, CancellationToken cancellationToken = default!);
    Task<EmployeeSummaryResponse?> GetEmployeeByIdAsync(int employeeId, CancellationToken cancellationToken = default!);
    Task<IEnumerable<EmployeesByDesignationResponse>> GetEmployeesByDesignationInScopeAsync(
        IEnumerable<short> designationIds,
        short? scopeTypeId,
        int? scopeReferenceId);
    //Task<IEnumerable<EmployeeSummaryResponse>> GetEmployeesByRoleInScopeAsync(
    //    short approverRuleId, short? scopeTypeId, int? scopeReferenceId);
    Task<int?> GetScopeReferenceIdAsync(int employeeId, short? scopeTypeId, CancellationToken cancellationToken = default!);
}
