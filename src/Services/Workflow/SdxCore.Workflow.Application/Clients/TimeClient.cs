using MassTransit.Middleware;
using SdxCore.Common.Models;
using SdxCore.Workflow.Application.Abstractions.Clients;
using SdxCore.Workflow.Application.DTOs.Time;
using System.Net.Http.Json;

namespace SdxCore.Workflow.Application.Clients;
public class TimeClient(HttpClient httpClient) : ITimeClient
{
    public async Task<IEnumerable<ScopeTypeResponse>> GetAllScopeTypeAsync(CancellationToken cancellationToken = default!)
    {
        var response = await httpClient.GetFromJsonAsync<ApiResponse<IEnumerable<ScopeTypeResponse>>>(
            $"api/v1/scope-types",
            cancellationToken);

        return response?.Data ?? [];
    }
}