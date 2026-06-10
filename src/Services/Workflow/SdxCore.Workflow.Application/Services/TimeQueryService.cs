using SdxCore.Common.Enums.Workflow;
using SdxCore.Workflow.Application.Contracts.Clients;
using SdxCore.Workflow.Application.Contracts.Services;
using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Services;

public class TimeQueryService : ITimeQueryService
{
    private readonly ITimeClient _timeClient;

    public TimeQueryService(ITimeClient timeClient)
    {
        _timeClient = timeClient;
    }

    public async Task<IEnumerable<ScopeTypeResponse>> GetAllScopeTypeAsync(CancellationToken cancellationToken = default)
    {
        return await _timeClient.GetAllScopeTypeAsync();
    }
}