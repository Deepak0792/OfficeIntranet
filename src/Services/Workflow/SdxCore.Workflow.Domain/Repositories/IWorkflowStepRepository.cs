using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Repositories;

public interface IWorkflowStepRepository : IRepository<WorkflowStep, short>
{
    Task<IEnumerable<WorkflowStep>> GetByDefinitionIdAsync(short definitionId, CancellationToken cancellationToken = default);
    Task<WorkflowStep?> GetWithApproversAsync(short id, CancellationToken cancellationToken = default);
    Task<WorkflowStep?> GetNextStepAsync(short definitionId, short currentStepNo, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, CancellationToken cancellationToken = default);
    Task ReorderAsync(short definitionId, short stepId, short newStepNo, CancellationToken cancellationToken = default);
}
