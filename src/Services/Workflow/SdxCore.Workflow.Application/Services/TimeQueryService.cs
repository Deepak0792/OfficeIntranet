using SdxCore.Common.Enums.Workflow;
using SdxCore.Workflow.Application.Abstractions.Clients;
using SdxCore.Workflow.Application.Abstractions.Services;
using SdxCore.Workflow.Application.DTOs.Time;

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