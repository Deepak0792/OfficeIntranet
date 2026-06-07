using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Contracts.Clients;
public interface ITimeClient
{
    Task<IEnumerable<ScopeTypeResponse>> GetAllScopeTypeAsync(CancellationToken cancellationToken = default!);
}