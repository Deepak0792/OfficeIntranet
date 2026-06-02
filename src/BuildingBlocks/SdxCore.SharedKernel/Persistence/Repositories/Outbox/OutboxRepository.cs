using Microsoft.EntityFrameworkCore;
using SdxCore.SharedKernel.Constant;
using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Entities;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.SharedKernel.Persistence.Outbox;

public class OutboxRepository<TDbContext> : BaseRepository<OutboxMessage, Guid, TDbContext>
    where TDbContext : DbContext
{
    public OutboxRepository(
        TDbContext dbContext,
        IRequestContext requestContext)
        : base(dbContext, requestContext)
    {
    }

    public async Task<List<OutboxMessage>> GetPendingAsync(
        int batchSize,
        CancellationToken cancellationToken)
    {
        return await _dbSet
            .Where(x => x.Status == OutboxStatus.Pending && x.IsActive)
            .OrderBy(x => x.CreatedAt)
            .Take(batchSize)
            .ToListAsync(cancellationToken);
    }

    public async Task MarkPublishedAsync(
        Guid id,
        CancellationToken cancellationToken)
    {
        var message = await GetByIdAsync(id, cancellationToken);

        if (message is null)
            return;

        message.Status = OutboxStatus.Published;
        message.PublishedAt = DateTime.UtcNow;
        message.LastUpdatedAt = DateTime.UtcNow;
        message.LastUpdatedBy = SystemUser.SystemUserId;

        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task MarkFailedAsync(
        Guid id,
        string error,
        CancellationToken cancellationToken)
    {
        var message = await GetByIdAsync(id, cancellationToken);

        if (message is null)
            return;

        message.RetryCount++;
        message.ErrorMessage = error;
        message.Status = OutboxStatus.Failed;
        message.LastUpdatedAt = DateTime.UtcNow;
        message.LastUpdatedBy = SystemUser.SystemUserId;

        await _dbContext.SaveChangesAsync(cancellationToken);
    }
}