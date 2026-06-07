using SdxCore.Workflow.Application.DTOs.Response;

namespace SdxCore.Workflow.Application.Contracts.Services
{
    public interface ITimeQueryService
    {
        Task<IEnumerable<ScopeTypeResponse>> GetAllScopeTypeAsync(CancellationToken cancellationToken = default!);
    }
}
