using SdxCore.Attendance.Application.Abstractions.Clients;
using SdxCore.Attendance.Application.DTOs.Time;
using SdxCore.Common.Models;
using System.Net.Http.Json;

namespace SdxCore.Attendance.Application.Clients;

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
