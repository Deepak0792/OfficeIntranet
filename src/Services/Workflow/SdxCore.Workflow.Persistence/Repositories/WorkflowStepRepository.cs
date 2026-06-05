using Microsoft.EntityFrameworkCore;
using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Repositories;
using SdxCore.Workflow.Persistence.Data;

namespace SdxCore.Workflow.Persistence.Repositories;

public class WorkflowStepRepository(WorkflowDbContext dbContext, IRequestContext requestContext) 
    : BaseRepository<WorkflowStep, short, WorkflowDbContext>(dbContext, requestContext), IWorkflowStepRepository
{
    public async Task<IEnumerable<WorkflowStep>> GetByDefinitionIdAsync(short definitionId, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Where(x => x.WorkflowDefinitionId == definitionId)
            .OrderBy(x => x.StepNo)
            .ToListAsync(cancellationToken);

    public async Task<WorkflowStep?> GetWithApproversAsync(short id, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Include(x => x.Approvers.Where(a => a.IsActive))
                .ThenInclude(a => a.Designations.Where(d => d.IsActive))
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

    public async Task<WorkflowStep?> GetNextStepAsync(short definitionId, short currentStepNo, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Where(x => x.WorkflowDefinitionId == definitionId
                     && x.StepNo > currentStepNo
                     && x.IsActive)
            .OrderBy(x => x.StepNo)
            .FirstOrDefaultAsync(cancellationToken);

    public async Task<bool> ToggleStatusAsync(short id, CancellationToken cancellationToken = default)
    {
        var entity = await GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;
        entity.IsActive = !entity.IsActive;
        Update(entity);
        return true;
    }

    public async Task ReorderAsync(short definitionId, short stepId, short newStepNo, CancellationToken cancellationToken = default)
    {
        // Shift existing steps to make room, then assign new StepNo
        var steps = await _dbSet
            .Where(x => x.WorkflowDefinitionId == definitionId && x.IsActive)
            .OrderBy(x => x.StepNo)
            .ToListAsync(cancellationToken);

        var target = steps.FirstOrDefault(x => x.Id == stepId);
        if (target is null) return;

        short oldStepNo = target.StepNo;

        if (oldStepNo == newStepNo) return;

        // Shift steps between old and new positions
        if (newStepNo < oldStepNo)
        {
            foreach (var s in steps.Where(x => x.StepNo >= newStepNo && x.StepNo < oldStepNo && x.Id != stepId))
            {
                s.StepNo++;
                Update(s);
            }
        }
        else
        {
            foreach (var s in steps.Where(x => x.StepNo > oldStepNo && x.StepNo <= newStepNo && x.Id != stepId))
            {
                s.StepNo--;
                Update(s);
            }
        }

        target.StepNo = newStepNo;
        Update(target);
    }
}
