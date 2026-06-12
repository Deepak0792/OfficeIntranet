using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Abstractions.Repositories;

public interface IWorkflowStepRepository : IRepository<WorkflowStep, Guid>
{
    Task<IEnumerable<WorkflowStep>> GetByDefinitionIdAsync(Guid definitionId, CancellationToken cancellationToken = default);
    Task<WorkflowStep?> GetWithApproversAsync(Guid id, CancellationToken cancellationToken = default);
    Task<WorkflowStep?> GetNextStepAsync(Guid definitionId, short currentStepNo, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, CancellationToken cancellationToken = default);
    Task ReorderAsync(Guid definitionId, Guid stepId, short newStepNo, CancellationToken cancellationToken = default);
}
