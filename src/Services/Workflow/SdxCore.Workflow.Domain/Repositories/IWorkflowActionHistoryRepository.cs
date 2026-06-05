using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Repositories;

public interface IWorkflowActionHistoryRepository : IRepository<WorkflowActionHistory, int>
{
    Task<IEnumerable<WorkflowActionHistory>> GetByInstanceIdAsync(int instanceId, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowActionHistory>> GetByTaskIdAsync(int taskId, CancellationToken cancellationToken = default);
}
