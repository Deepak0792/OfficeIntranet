using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Repositories;

public interface IWorkflowDefinitionRepository : IRepository<WorkflowDefinition, short>
{
    Task<WorkflowDefinition?> GetByCodeAsync(string workflowCode, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowDefinition>> GetByModuleIdAsync(short moduleId, CancellationToken cancellationToken = default);
    Task<WorkflowDefinition?> GetWithStepsAsync(short id, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, CancellationToken cancellationToken = default);
}
