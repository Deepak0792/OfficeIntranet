using SdxCore.Workflow.Application.DTOs.Time;

namespace SdxCore.Workflow.Application.Abstractions.Services
{
    public interface ITimeQueryService
    {
        Task<IEnumerable<ScopeTypeResponse>> GetAllScopeTypeAsync(CancellationToken cancellationToken = default!);
    }
}
