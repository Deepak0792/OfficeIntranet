using SdxCore.Workflow.Application.DTOs.Time;

namespace SdxCore.Workflow.Application.Abstractions.Clients;
public interface ITimeClient
{
    Task<IEnumerable<ScopeTypeResponse>> GetAllScopeTypeAsync(CancellationToken cancellationToken = default!);
}