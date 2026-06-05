using Microsoft.EntityFrameworkCore;
using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Repositories;
using SdxCore.Workflow.Persistence.Data;

namespace SdxCore.Workflow.Persistence.Repositories;

public class WorkflowTaskRepository(WorkflowDbContext dbContext, IRequestContext requestContext) 
    : BaseRepository<WorkflowTask, int, WorkflowDbContext>(dbContext, requestContext), IWorkflowTaskRepository
{

    public async Task<WorkflowTask?> GetByIdWithDetailsAsync(int id, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Include(x => x.Instance)
                .ThenInclude(i => i.Definition)
            .Include(x => x.Instance)
                .ThenInclude(i => i.Module)
            .Include(x => x.Step)
            .Include(x => x.StepApprover)
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

    public async Task<IEnumerable<WorkflowTask>> GetByInstanceIdAsync(int instanceId, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Include(x => x.Step)
            .Include(x => x.StepApprover)
            .Where(x => x.WorkflowInstanceId == instanceId)
            .OrderBy(x => x.AssignedAt)
            .ToListAsync(cancellationToken);

    public async Task<IEnumerable<WorkflowTask>> GetMyPendingTasksAsync(
        int employeeId, string? moduleCode = null, CancellationToken cancellationToken = default)
    {
        var q = _dbSet
            .Include(x => x.Instance)
                .ThenInclude(i => i.Definition)
            .Include(x => x.Instance)
                .ThenInclude(i => i.Module)
            .Where(x => x.AssignedToEmployeeId == employeeId && x.TaskStatus == "PENDING");

        if (!string.IsNullOrEmpty(moduleCode))
            q = q.Where(x => x.Instance.Module.ModuleCode == moduleCode);

        return await q.OrderByDescending(x => x.AssignedAt).ToListAsync(cancellationToken);
    }

    public async Task<(IEnumerable<WorkflowTask> Items, int TotalCount)> GetMyPendingPagedAsync(
        int employeeId, string? moduleCode, int page, int pageSize, CancellationToken cancellationToken = default)
    {
        var q = _dbSet
            .Include(x => x.Instance)
                .ThenInclude(i => i.Definition)
            .Include(x => x.Instance)
                .ThenInclude(i => i.Module)
            .Where(x => x.AssignedToEmployeeId == employeeId && x.TaskStatus == "PENDING");

        if (!string.IsNullOrEmpty(moduleCode))
            q = q.Where(x => x.Instance.Module.ModuleCode == moduleCode);

        var total = await q.CountAsync(cancellationToken);
        var items = await q
            .OrderByDescending(x => x.AssignedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);

        return (items, total);
    }
}
