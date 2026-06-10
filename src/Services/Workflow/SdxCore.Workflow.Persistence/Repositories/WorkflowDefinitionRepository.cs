using Microsoft.EntityFrameworkCore;
using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Repositories;
using SdxCore.Workflow.Persistence.Data;

namespace SdxCore.Workflow.Persistence.Repositories;

public class WorkflowDefinitionRepository(WorkflowDbContext dbContext, IUserContext requestContext) 
    : BaseRepository<WorkflowDefinition, Guid, WorkflowDbContext>(dbContext, requestContext), IWorkflowDefinitionRepository
{
    public async Task<WorkflowDefinition?> GetByCodeAsync(string workflowCode, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Include(x => x.Module)
            .FirstOrDefaultAsync(x => x.WorkflowCode == workflowCode, cancellationToken);

    public async Task<IEnumerable<WorkflowDefinition>> GetByModuleIdAsync(Guid moduleId, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Include(x => x.Module)
            .Where(x => x.WorkflowModuleId == moduleId)
            .OrderByDescending(x => x.VersionNo)
            .ToListAsync(cancellationToken);

    public async Task<WorkflowDefinition?> GetWithStepsAsync(Guid id, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Include(x => x.Module)
            .Include(x => x.Steps.Where(s => s.IsActive))
                .ThenInclude(s => s.Approvers.Where(a => a.IsActive))
                    .ThenInclude(a => a.Designations.Where(d => d.IsActive))
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

    public async Task<bool> ToggleStatusAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var entity = await GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;
        entity.IsActive = !entity.IsActive;
        Update(entity);
        return true;
    }
}
