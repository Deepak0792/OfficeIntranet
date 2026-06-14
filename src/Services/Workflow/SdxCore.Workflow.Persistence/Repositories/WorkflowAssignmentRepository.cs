using Microsoft.EntityFrameworkCore;
using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Workflow.Domain.Abstractions.Repositories;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Persistence.Data;

namespace SdxCore.Workflow.Persistence.Repositories;

public class WorkflowAssignmentRepository(WorkflowDbContext dbContext) :
    BaseRepository<WorkflowAssignment, Guid, WorkflowDbContext>(dbContext),
    IWorkflowAssignmentRepository
{
    public async Task<IEnumerable<WorkflowAssignment>> GetByDefinitionIdAsync(Guid definitionId, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Include(x => x.Definition)
            .Where(x => x.WorkflowDefinitionId == definitionId)
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
