using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Repositories;

public interface IWorkflowTaskRepository : IRepository<WorkflowTask, Guid>
{
    Task<WorkflowTask?> GetByIdWithDetailsAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowTask>> GetByInstanceIdAsync(Guid instanceId, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowTask>> GetMyPendingTasksAsync(Guid employeeId, string? moduleCode = null, CancellationToken cancellationToken = default);
    Task<(IEnumerable<WorkflowTask> Items, int TotalCount)> GetMyPendingPagedAsync(
        Guid employeeId, string? moduleCode, int page, int pageSize, CancellationToken cancellationToken = default);
}
