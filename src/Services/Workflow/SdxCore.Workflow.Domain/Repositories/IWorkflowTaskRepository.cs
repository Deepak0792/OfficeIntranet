using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Repositories;

public interface IWorkflowTaskRepository : IRepository<WorkflowTask, int>
{
    Task<WorkflowTask?> GetByIdWithDetailsAsync(int id, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowTask>> GetByInstanceIdAsync(int instanceId, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowTask>> GetMyPendingTasksAsync(int employeeId, string? moduleCode = null, CancellationToken cancellationToken = default);
    Task<(IEnumerable<WorkflowTask> Items, int TotalCount)> GetMyPendingPagedAsync(
        int employeeId, string? moduleCode, int page, int pageSize, CancellationToken cancellationToken = default);
}
