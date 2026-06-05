using Microsoft.EntityFrameworkCore;
using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Repositories;
using SdxCore.Workflow.Persistence.Data;

namespace SdxCore.Workflow.Persistence.Repositories;

public class WorkflowActionHistoryRepository(WorkflowDbContext dbContext, IRequestContext requestContext)
    : BaseRepository<WorkflowActionHistory, int, WorkflowDbContext>(dbContext, requestContext), IWorkflowActionHistoryRepository
{
    public async Task<IEnumerable<WorkflowActionHistory>> GetByInstanceIdAsync(int instanceId, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Include(x => x.Step)
            .Include(x => x.Task)
            .Where(x => x.WorkflowInstanceId == instanceId && x.IsActive)
            .OrderBy(x => x.ActionAt)
            .ToListAsync(cancellationToken);

    public async Task<IEnumerable<WorkflowActionHistory>> GetByTaskIdAsync(int taskId, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Include(x => x.Step)
            .Where(x => x.WorkflowTaskId == taskId && x.IsActive)
            .OrderBy(x => x.ActionAt)
            .ToListAsync(cancellationToken);
}
