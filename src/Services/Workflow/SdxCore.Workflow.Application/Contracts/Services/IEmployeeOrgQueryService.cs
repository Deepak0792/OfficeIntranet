using SdxCore.Workflow.Application.Services;

namespace SdxCore.Workflow.Application.Contracts.Services;

public interface IEmployeeOrgQueryService
{
    Task<EmployeeOrgInfo?> GetReportingManagerAsync(int employeeId);
    Task<EmployeeOrgInfo?> GetEmployeeByIdAsync(int employeeId);
    Task<IEnumerable<EmployeeOrgInfo>> GetEmployeesByDesignationInScopeAsync(
        IEnumerable<short> designationIds, short? scopeTypeId, int? scopeReferenceId);
    Task<IEnumerable<EmployeeOrgInfo>> GetEmployeesByRoleInScopeAsync(
        short approverRuleId, short? scopeTypeId, int? scopeReferenceId);
    Task<int?> GetScopeReferenceIdAsync(int employeeId, short? scopeTypeId);
}
