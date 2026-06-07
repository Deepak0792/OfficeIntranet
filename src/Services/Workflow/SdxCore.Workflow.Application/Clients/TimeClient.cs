using MassTransit.Middleware;
using SdxCore.Workflow.Application.Contracts.Clients;
using SdxCore.Workflow.Application.DTOs.Response;
using System.Net.Http.Json;

namespace SdxCore.Workflow.Application.Clients;
public class TimeClient : ITimeClient
{
    private readonly HttpClient _httpClient;

    public TimeClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<IEnumerable<ScopeTypeResponse>> GetAllScopeTypeAsync(CancellationToken cancellationToken = default!)
    {
        var scopeTypes = await _httpClient.GetFromJsonAsync<IEnumerable<ScopeTypeResponse>>(
            $"api/v1/scope-types",
            cancellationToken);

        return scopeTypes ?? Enumerable.Empty<ScopeTypeResponse>();
    }
}