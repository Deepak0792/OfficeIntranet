using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Repositories;

public interface IWorkflowStepApproverRepository : IRepository<WorkflowStepApprover, short>
{
    Task<IEnumerable<WorkflowStepApprover>> GetByStepIdAsync(short stepId, CancellationToken cancellationToken = default);
    Task<WorkflowStepApprover?> GetWithDesignationsAsync(short id, CancellationToken cancellationToken = default);
    Task<bool> ToggleStatusAsync(short id, CancellationToken cancellationToken = default);

    /// <summary>
    /// Returns all DesignationIds mapped to this approver rule via
    /// WorkflowStepApproverDesignation. Used by WorkflowApproverResolver
    /// when ApproverType = DESIGNATION.
    /// </summary>
    Task<IEnumerable<short>> GetDesignationIdsAsync(short approverId, CancellationToken cancellationToken = default);
}
