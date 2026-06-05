using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Repositories;

public interface IWorkflowModuleRepository : IRepository<WorkflowModule, short>
{
    Task<WorkflowModule?> GetByCodeAsync(string moduleCode, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowModule>> GetAllAsync(bool activeOnly = true, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, CancellationToken cancellationToken = default);
    Task<bool> ExistsAsync(string moduleCode, CancellationToken cancellationToken = default);
}
