using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Abstractions.Repositories;

public interface IWorkflowActionHistoryRepository : IRepository<WorkflowActionHistory, Guid>
{
    Task<IEnumerable<WorkflowActionHistory>> GetByInstanceIdAsync(Guid instanceId, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowActionHistory>> GetByTaskIdAsync(Guid taskId, CancellationToken cancellationToken = default);
}
