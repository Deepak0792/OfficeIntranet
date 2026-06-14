using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Abstractions.Repositories;

public interface IWorkflowAssignmentRepository : IRepository<WorkflowAssignment, Guid>
{
    Task<IEnumerable<WorkflowAssignment>> GetByDefinitionIdAsync(Guid definitionId, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, CancellationToken cancellationToken = default);
}
