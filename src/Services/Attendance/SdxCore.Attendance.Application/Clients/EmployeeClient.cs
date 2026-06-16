using Microsoft.AspNetCore.WebUtilities;
using SdxCore.Attendance.Application.Abstractions.Clients;
using SdxCore.Attendance.Application.DTOs.Employee;
using System.Net.Http.Json;

namespace SdxCore.Attendance.Application.Clients;

public class EmployeeClient(HttpClient httpClient) : IEmployeeClient
{
    public async Task<EmployeeSummaryResponse?> GetEmployeeSummaryByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => await httpClient.GetFromJsonAsync<EmployeeSummaryResponse>($"api/v1/employees/{id}/summary", cancellationToken);

    public async Task<IEnumerable<EmployeesByDesignationResponse>> GetEmployeesByDesignationInScopeAsync(
        IEnumerable<Guid> designationIds, string? scopeCode, Guid? scopeReferenceId, CancellationToken cancellationToken = default)
    {
        var queryParams = new List<KeyValuePair<string, string>>();
        foreach (var id in designationIds)
            queryParams.Add(new("designationIds", id.ToString()));
        if (scopeCode is not null)
            queryParams.Add(new("scopeCode", scopeCode));
        if (scopeReferenceId.HasValue)
            queryParams.Add(new("scopeReferenceId", scopeReferenceId.Value.ToString()));

        var url = QueryHelpers.AddQueryString("api/v1/employees/by-designation", queryParams!);
        var response = await httpClient.GetFromJsonAsync<IEnumerable<EmployeesByDesignationResponse>>(url, cancellationToken);
        return response ?? [];
    }
}
