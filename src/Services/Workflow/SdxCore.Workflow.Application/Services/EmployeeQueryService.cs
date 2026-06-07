using SdxCore.Workflow.Application.Contracts.Clients;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Services;

public class EmployeeQueryService : IEmployeeQueryService
{
    private readonly IEmployeeClient _employeeClient;

    public EmployeeQueryService(IEmployeeClient employeeClient)
    {
        _employeeClient = employeeClient;
    }

    public async Task<EmployeeSummaryResponse?> GetEmployeeByIdAsync(int employeeId, CancellationToken cancellationToken = default!)
    {
        return await _employeeClient.GetEmployeeeSummaryAsync(employeeId, cancellationToken);
    }

    public async Task<EmployeeSummaryResponse?> GetReportingManagerAsync(int employeeId, CancellationToken cancellationToken = default!)
    {
        var employee = await GetEmployeeByIdAsync(employeeId)
            ?? throw new InvalidOperationException($"Employee service returned null for Employee Id {employeeId}");

        var managerId = employee.DirectManagerId
            ?? throw new InvalidOperationException($"Employee Reporting Manager is not configured for Employee Id {employeeId}");

        return await GetEmployeeByIdAsync(managerId);
    }

    public async Task<IEnumerable<EmployeesByDesignationResponse>> GetEmployeesByDesignationInScopeAsync(
        IEnumerable<short> designationIds,
        short? scopeTypeId,
        int? scopeReferenceId)
    {
        // Since this is cross-service filtering,
        // delegate to Employee API search endpoint

        return await _employeeClient.GetEmployeesByDesignationInScopeAsync(
            designationIds,
            scopeTypeId,
            scopeReferenceId,
            CancellationToken.None);
    }

    //public async Task<IEnumerable<EmployeeSummaryResponse>> GetEmployeesByRoleInScopeAsync(
    //    short approverRuleId,
    //    short? scopeTypeId,
    //    int? scopeReferenceId)
    //{
    //    return await _employeeClient.GetEmployeeeSummaryAsync(
    //        approverRuleId,
    //        scopeTypeId,
    //        scopeReferenceId,
    //        CancellationToken.None);
    //}

    public async Task<int?> GetScopeReferenceIdAsync(int employeeId, short? scopeTypeId, CancellationToken cancellationToken = default!)
    {
        var employee = await _employeeClient.GetEmployeeeSummaryAsync(employeeId, cancellationToken);

        if (employee == null)
            return null;

        return scopeTypeId switch
        {
            2 => 1,//TO DO Office Location CountryId
            3 => employee.PrimaryLegalEntityId,
            4 => employee.PrimaryLocationId,
            5 => employee.PrimaryDepartmentId,
            6 => employee.PrimaryTeamId,
            7 => employee.EmployeeId,
            _ => null
        };
    }
}