using Microsoft.AspNetCore.WebUtilities;
using SdxCore.Attendance.Application.Abstractions.Clients;
using SdxCore.Attendance.Application.DTOs.Employee;

namespace SdxCore.Attendance.Application.Clients;

public class EmployeeClient(HttpClient httpClient) : IEmployeeClient
{
    public async Task<EmployeeSummaryResponse?> GetEmployeeSummaryByIdAsync(
    Guid id,
    CancellationToken cancellationToken = default)
    {
        var response = await httpClient.GetAsync(
            $"api/v1/employees/{id}/summary",
            cancellationToken);

        return await response.ReadApiResponseAsync<EmployeeSummaryResponse>(
            cancellationToken);
    }
    public async Task<IReadOnlyList<EmployeeSummaryResponse>> GetEmployeesAsync(
    bool isActive = true,
    CancellationToken cancellationToken = default)
    {
        var response = await httpClient.GetAsync(
            $"api/v1/employees/active?isActive={isActive}",
            cancellationToken);

        return await response.ReadApiResponseAsync<List<EmployeeSummaryResponse>>(
                   cancellationToken)
               ?? [];
    }

    public async Task<IEnumerable<EmployeesByDesignationResponse>>
     GetEmployeesByDesignationInScopeAsync(
         IEnumerable<Guid> designationIds,
         string? scopeCode,
         Guid? scopeReferenceId,
         CancellationToken cancellationToken = default)
    {
        var queryParams = new List<KeyValuePair<string, string>>();

        foreach (var id in designationIds)
            queryParams.Add(new("designationIds", id.ToString()));

        if (!string.IsNullOrWhiteSpace(scopeCode))
            queryParams.Add(new("scopeCode", scopeCode));

        if (scopeReferenceId.HasValue)
            queryParams.Add(new("scopeReferenceId", scopeReferenceId.Value.ToString()));

        var url = QueryHelpers.AddQueryString(
            "api/v1/employees/by-designation",
            queryParams!);

        var response = await httpClient.GetAsync(url, cancellationToken);

        return await response.ReadApiResponseAsync<
            IEnumerable<EmployeesByDesignationResponse>>(
            cancellationToken)
            ?? [];
    }
}
