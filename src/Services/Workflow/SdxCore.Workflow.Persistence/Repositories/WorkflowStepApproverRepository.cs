using Microsoft.EntityFrameworkCore;
using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Repositories;
using SdxCore.Workflow.Persistence.Data;

namespace SdxCore.Workflow.Persistence.Repositories;

public class WorkflowStepApproverRepository(WorkflowDbContext dbContext) :
    BaseRepository<WorkflowStepApprover, Guid, WorkflowDbContext>(dbContext),
    IWorkflowStepApproverRepository
{
    public async Task<IEnumerable<WorkflowStepApprover>> GetByStepIdAsync(Guid stepId, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Include(x => x.Designations.Where(d => d.IsActive))
            .Where(x => x.WorkflowStepId == stepId)
            .OrderBy(x => x.PriorityOrder)
            .ToListAsync(cancellationToken);

    public async Task<WorkflowStepApprover?> GetWithDesignationsAsync(Guid id, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Include(x => x.Designations.Where(d => d.IsActive))
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

    public async Task<IEnumerable<Guid>> GetDesignationIdsAsync(Guid approverId, CancellationToken cancellationToken = default) =>
        await _dbContext.WorkflowStepApproverDesignations
            .Where(x => x.WorkflowStepApproverId == approverId && x.IsActive)
            .Select(x => x.DesignationId)
            .ToListAsync(cancellationToken);

    public async Task<bool> ToggleStatusAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;
        entity.IsActive = !entity.IsActive;
        Update(entity);
        return true;
    }
}
