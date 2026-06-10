using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Repositories;

public interface IWorkflowStepApproverDesignationRepository : IRepository<WorkflowStepApproverDesignation, Guid>
{
    Task<IEnumerable<WorkflowStepApproverDesignation>> GetByApproverIdAsync(Guid approverId, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(Guid approverId, Guid designationId, CancellationToken cancellationToken = default);
    Task<bool> ExistsAsync(Guid approverId, Guid designationId, CancellationToken cancellationToken = default);
}
