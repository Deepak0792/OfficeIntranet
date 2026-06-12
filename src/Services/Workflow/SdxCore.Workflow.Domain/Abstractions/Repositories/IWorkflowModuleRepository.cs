using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Abstractions.Repositories;

public interface IWorkflowModuleRepository : IRepository<WorkflowModule, Guid>
{
    Task<WorkflowModule?> GetByCodeAsync(string moduleCode, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowModule>> GetAllAsync(bool activeOnly = true, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, CancellationToken cancellationToken = default);
    Task<bool> ExistsAsync(string moduleCode, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowAssignmentSummary>> GetWorkflowAssignmentsAsync(string moduleCode, CancellationToken cancellationToken = default);
}
