using Microsoft.AspNetCore.WebUtilities;
using SdxCore.Common.Models;
using SdxCore.Workflow.Application.Contracts.Clients;
using SdxCore.Workflow.Application.DTOs.Response;
using System.Net.Http.Json;

namespace SdxCore.Workflow.Application.Clients;
public class EmployeeClient : IEmployeeClient
{
    private readonly HttpClient _httpClient;

    public EmployeeClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<EmployeeSummaryResponse?> GetEmployeeeSummaryAsync(
        int id,
        CancellationToken cancellationToken = default!)
    {
        var employee = await _httpClient.GetFromJsonAsync<EmployeeSummaryResponse>(
           $"api/v1/employees/{id}/summary",
           cancellationToken);

        return employee;
    }

    public async Task<IEnumerable<EmployeesByDesignationResponse>> GetEmployeesByDesignationInScopeAsync(
            IEnumerable<short> designationIds,
            short? scopeTypeId,
            int? scopeReferenceId,
            CancellationToken cancellationToken)
    {
        var queryParams = new List<KeyValuePair<string, string>>();

        foreach (var designationId in designationIds)
        {
            queryParams.Add(new("designationIds", designationId.ToString()));
        }

        if (scopeTypeId.HasValue)
            queryParams.Add(new("scopeTypeId", scopeTypeId.Value.ToString()));

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