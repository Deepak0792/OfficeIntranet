using Microsoft.EntityFrameworkCore;
using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Workflow.Domain.Abstractions.Repositories;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Persistence.Data;

namespace SdxCore.Workflow.Persistence.Repositories;

public class WorkflowStepApproverDesignationRepository(WorkflowDbContext dbContext) :
    BaseRepository<WorkflowStepApproverDesignation, Guid, WorkflowDbContext>(dbContext),
    IWorkflowStepApproverDesignationRepository
{
    public async Task<IEnumerable<WorkflowStepApproverDesignation>> GetByApproverIdAsync(Guid approverId, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Where(x => x.WorkflowStepApproverId == approverId && x.IsActive)
            .ToListAsync(cancellationToken);

    public async Task<bool> DeleteAsync(Guid approverId, Guid designationId, CancellationToken cancellationToken = default)
    {
        var entity = await _dbSet
            .FirstOrDefaultAsync(x =>
                x.WorkflowStepApproverId == approverId &&
                x.DesignationId == designationId, cancellationToken);
        if (entity is null) return false;
        _dbSet.Remove(entity);
        return true;
    }

    public async Task<bool> ExistsAsync(Guid approverId, Guid designationId, CancellationToken cancellationToken = default) =>
        await _dbSet
            .AnyAsync(x => x.WorkflowStepApproverId == approverId &&
                           x.DesignationId == designationId, cancellationToken);
}
