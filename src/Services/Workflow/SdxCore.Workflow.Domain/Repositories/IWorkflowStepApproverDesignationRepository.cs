using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Workflow.Domain.Entities;

namespace SdxCore.Workflow.Domain.Repositories;

public interface IWorkflowStepApproverDesignationRepository : IRepository<WorkflowStepApproverDesignation, short>
{
    Task<IEnumerable<WorkflowStepApproverDesignation>> GetByApproverIdAsync(short approverId, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(short approverId, short designationId, CancellationToken cancellationToken = default);
    Task<bool> ExistsAsync(short approverId, short designationId, CancellationToken cancellationToken = default);
}
