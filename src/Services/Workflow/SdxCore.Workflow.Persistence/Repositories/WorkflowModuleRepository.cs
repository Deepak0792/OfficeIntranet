using Microsoft.EntityFrameworkCore;
using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Repositories;
using SdxCore.Workflow.Persistence.Data;

namespace SdxCore.Workflow.Persistence.Repositories;

public class WorkflowModuleRepository : BaseRepository<WorkflowModule, short, WorkflowDbContext>, IWorkflowModuleRepository
{
    private readonly WorkflowDbContext dbContext;
    public WorkflowModuleRepository(WorkflowDbContext dbContext, IUserContext requestContext):base(dbContext, requestContext)
    {
        this.dbContext = dbContext;
    }

    public async Task<WorkflowModule?> GetByCodeAsync(string moduleCode, CancellationToken cancellationToken = default) =>
        await _dbSet.FirstOrDefaultAsync(x => x.ModuleCode == moduleCode, cancellationToken);

    public async Task<IEnumerable<WorkflowModule>> GetAllAsync(bool activeOnly = true, CancellationToken cancellationToken = default)
    {
        var q = _dbSet.AsQueryable();
        if (activeOnly) q = q.Where(x => x.IsActive);
        return await q.OrderBy(x => x.ModuleCode).ToListAsync(cancellationToken);
    }

    public async Task<bool> ToggleStatusAsync(short id, CancellationToken cancellationToken = default)
    {
        var entity = await GetByIdAsync(id, cancellationToken);
        if (entity is null) return false;
        entity.IsActive = !entity.IsActive;
        Update(entity);
        return true;
    }

    public async Task<bool> ExistsAsync(string moduleCode, CancellationToken cancellationToken = default) =>
        await _dbSet.AnyAsync(x => x.ModuleCode == moduleCode, cancellationToken);

    public async Task<IEnumerable<WorkflowAssignmentSummary>> GetWorkflowAssignmentsAsync(
    string moduleCode, CancellationToken cancellationToken = default)
    {
        return await dbContext.WorkflowAssignmentSummaries
            .Where(x => x.ModuleCode == moduleCode)
            .OrderBy(x => x.PriorityOrder)
            .ToListAsync(cancellationToken);
    }
}
