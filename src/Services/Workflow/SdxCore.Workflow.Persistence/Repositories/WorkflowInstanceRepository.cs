using Microsoft.EntityFrameworkCore;
using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Workflow.Domain.Entities;
using SdxCore.Workflow.Domain.Repositories;
using SdxCore.Workflow.Persistence.Data;

namespace SdxCore.Workflow.Persistence.Repositories;

public class WorkflowInstanceRepository(WorkflowDbContext dbContext, IUserContext requestContext) 
    : BaseRepository<WorkflowInstance, int, WorkflowDbContext>(dbContext, requestContext), IWorkflowInstanceRepository
{
    public async Task<WorkflowInstance?> GetByIdWithDetailsAsync(int id, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Include(x => x.Definition)
            .Include(x => x.Module)
            .Include(x => x.CurrentStep)
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

    public async Task<WorkflowInstance?> GetByTransactionAsync(
        string moduleCode, int referenceTransactionId, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Include(x => x.Definition)
            .Include(x => x.Module)
            .Include(x => x.CurrentStep)
            .Where(x => x.Module.ModuleCode == moduleCode &&
                        x.ReferenceTransactionId == referenceTransactionId &&
                        x.IsActive)
            .OrderByDescending(x => x.CreatedAt)
            .FirstOrDefaultAsync(cancellationToken);

    public async Task<(IEnumerable<WorkflowInstance> Items, int TotalCount)> GetPagedAsync(
        int pageNumber, int pageSize,
        string? moduleCode, string? status,
        int? initiatedBy, DateTime? fromDate, DateTime? toDate, CancellationToken cancellationToken = default)
    {
        var q = _dbSet
            .Include(x => x.Definition)
            .Include(x => x.Module)
            .Include(x => x.CurrentStep)
            .Where(x => x.IsActive)
            .AsQueryable();

        if (!string.IsNullOrEmpty(moduleCode))
            q = q.Where(x => x.Module.ModuleCode == moduleCode);
        if (!string.IsNullOrEmpty(status))
            q = q.Where(x => x.WorkflowStatus == status);
        if (initiatedBy.HasValue)
            q = q.Where(x => x.CreatedBy == initiatedBy.Value);
        if (fromDate.HasValue)
            q = q.Where(x => x.CreatedAt >= fromDate.Value);
        if (toDate.HasValue)
            q = q.Where(x => x.CreatedAt <= toDate.Value);

        var total = await q.CountAsync(cancellationToken);
        var items = await q
            .OrderByDescending(x => x.CreatedAt)
            .Skip((pageNumber - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);
        return (items, total);
    }

    public async Task<IEnumerable<WorkflowInstance>> GetMySubmissionsAsync(int employeeId, CancellationToken cancellationToken = default) =>
        await _dbSet
            .Include(x => x.Definition)
            .Include(x => x.Module)
            .Include(x => x.CurrentStep)
            .Where(x => x.CreatedBy == employeeId && x.IsActive)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync(cancellationToken);

    public Task<bool> CancelAsync(int id, int actionBy, CancellationToken cancellationToken = default) => Task.FromResult(true); // handled by engine
    public Task<bool> WithdrawAsync(int id, int actionBy, CancellationToken cancellationToken = default) => Task.FromResult(true); // handled by engine
}
