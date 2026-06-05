using Microsoft.EntityFrameworkCore;
using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Repositories;
using SdxCore.Workflow.Persistence.Data;

namespace SdxCore.Workflow.Persistence.Repositories;

public class WorkflowStepApproverDesignationRepository(WorkflowDbContext dbContext, IRequestContext requestContext)
    : BaseRepository<WorkflowStepApproverDesignation, short, WorkflowDbContext>(dbContext, requestContext), IWorkflowStepApproverDesignationRepository
{
    public async Task<IEnumerable<WorkflowStepApproverDesignation>> GetByApproverIdAsync(short approverId, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Where(x => x.WorkflowStepApproverId == approverId && x.IsActive)
            .ToListAsync(cancellationToken);

    public async Task<bool> DeleteAsync(short approverId, short designationId, CancellationToken cancellationToken = default)
    {
        var entity = await _dbSet
            .FirstOrDefaultAsync(x =>
                x.WorkflowStepApproverId == approverId &&
                x.DesignationId == designationId, cancellationToken);
        if (entity is null) return false;
        _dbSet.Remove(entity);
        return true;
    }

    public async Task<bool> ExistsAsync(short approverId, short designationId, CancellationToken cancellationToken = default) =>
        await _dbSet
            .AnyAsync(x => x.WorkflowStepApproverId == approverId &&
                           x.DesignationId == designationId, cancellationToken);
}
