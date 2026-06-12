using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Abstractions.Repositories;

public interface IWorkflowDefinitionRepository : IRepository<WorkflowDefinition, Guid>
{
    Task<WorkflowDefinition?> GetByCodeAsync(string workflowCode, CancellationToken cancellationToken = default);
    Task<IEnumerable<WorkflowDefinition>> GetByModuleIdAsync(Guid moduleId, CancellationToken cancellationToken = default);
    Task<WorkflowDefinition?> GetWithStepsAsync(Guid id, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, CancellationToken cancellationToken = default);
}
