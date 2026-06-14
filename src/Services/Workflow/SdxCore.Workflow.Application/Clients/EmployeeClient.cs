using Microsoft.AspNetCore.WebUtilities;
using SdxCore.Common.Models;
using SdxCore.Workflow.Application.Abstractions.Clients;
using SdxCore.Workflow.Application.DTOs.Employee;
using System.Net.Http.Json;

namespace SdxCore.Workflow.Application.Clients;
public class EmployeeClient : IEmployeeClient
{
    private readonly HttpClient _httpClient;

    public EmployeeClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<EmployeeSummaryResponse?> GetEmployeeeSummaryByIdAsync(
        Guid id,
        CancellationToken cancellationToken = default!)
    {
        var employee = await _httpClient.GetFromJsonAsync<EmployeeSummaryResponse>(
           $"api/v1/employees/{id}/summary",
           cancellationToken);

        return employee;
    }

    public async Task<IEnumerable<EmployeesByDesignationResponse>> GetEmployeesByDesignationInScopeAsync(
            IEnumerable<Guid> designationIds,
            string? scopeCode,
            Guid? scopeReferenceId,
            CancellationToken cancellationToken)
    {
        var queryParams = new List<KeyValuePair<string, string>>();

        foreach (var designationId in designationIds)
        {
            queryParams.Add(new("designationIds", designationId.ToString()));
        }

        if (scopeCode is not null)
        {
            queryParams.Add(new("scopeCode", scopeCode));
        }

        if (scopeReferenceId.HasValue)
            queryParams.Add(new("scopeReferenceId", scopeReferenceId.Value.ToString()));

        var url = QueryHelpers.AddQueryString(
            "api/v1/employees/by-designation",
            queryParams!);

        var response = await _httpClient.GetFromJsonAsync<
            ApiResponse<IEnumerable<EmployeesByDesignationResponse>>>(
            url,
            cancellationToken);

        return response?.Data ?? Enumerable.Empty<EmployeesByDesignationResponse>();
    }
}