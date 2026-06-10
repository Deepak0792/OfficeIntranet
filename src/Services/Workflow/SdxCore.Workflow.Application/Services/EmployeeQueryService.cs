using SdxCore.Common.Enums.Workflow;
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

    public async Task<EmployeeSummaryResponse?> GetEmployeeByIdAsync(Guid employeeId, CancellationToken cancellationToken = default!)
    {
        return await _employeeClient.GetEmployeeeSummaryAsync(employeeId, cancellationToken);
    }

    public async Task<EmployeeSummaryResponse?> GetReportingManagerAsync(Guid employeeId, CancellationToken cancellationToken = default!)
    {
        var employee = await GetEmployeeByIdAsync(employeeId)
            ?? throw new InvalidOperationException($"Employee service returned null for Employee Id {employeeId}");

        var managerId = employee.DirectManagerId
            ?? throw new InvalidOperationException($"Employee Reporting Manager is not configured for Employee Id {employeeId}");

        return await GetEmployeeByIdAsync(managerId);
    }

    public async Task<IEnumerable<EmployeesByDesignationResponse>> GetEmployeesByDesignationInScopeAsync(
        IEnumerable<Guid> designationIds,
        string? scopeCode,
        Guid? scopeReferenceId)
    {
        // Since this is cross-service filtering,
        // delegate to Employee API search endpoint

        return await _employeeClient.GetEmployeesByDesignationInScopeAsync(
            designationIds,
            scopeCode,
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

    public async Task<Guid?> GetScopeReferenceIdAsync(Guid employeeId, string? scopeCode, CancellationToken cancellationToken = default!)
    {
        var employee = await _employeeClient.GetEmployeeeSummaryAsync(employeeId, cancellationToken);

        if (employee == null)
            return null;

        return scopeCode switch
        {
            ScopeTypeCodes.Country => employee.PrimaryLocationId,//TO DO Office Location CountryId
            ScopeTypeCodes.LegalEntity => employee.PrimaryLegalEntityId,
            ScopeTypeCodes.Office => employee.PrimaryLocationId,
            ScopeTypeCodes.Department => employee.PrimaryDepartmentId,
            ScopeTypeCodes.Team => employee.PrimaryTeamId,
            ScopeTypeCodes.Employee => employee.EmployeeId,
            _ => null
        };
    }
}