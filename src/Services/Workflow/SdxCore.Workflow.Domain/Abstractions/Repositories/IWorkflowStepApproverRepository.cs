using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Abstractions.Repositories;

public interface IWorkflowStepApproverRepository : IRepository<WorkflowStepApprover, Guid>
{
    Task<IEnumerable<WorkflowStepApprover>> GetByStepIdAsync(Guid stepId, CancellationToken cancellationToken = default);
    Task<WorkflowStepApprover?> GetWithDesignationsAsync(Guid id, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(Guid id, CancellationToken cancellationToken = default);

    /// <summary>
    /// Returns all DesignationIds mapped to this approver rule via
    /// WorkflowStepApproverDesignation. Used by WorkflowApproverResolver
    /// when ApproverType = DESIGNATION.
    /// </summary>
    Task<IEnumerable<Guid>> GetDesignationIdsAsync(Guid approverId, CancellationToken cancellationToken = default);
}
