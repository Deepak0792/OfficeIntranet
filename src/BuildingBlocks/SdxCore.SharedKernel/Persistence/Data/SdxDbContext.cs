using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;

namespace SdxCore.SharedKernel.Persistence.Data;

public abstract class SdxDbContext : DbContext
{
    protected SdxDbContext(DbContextOptions options)
        : base(options)
    {
    }

    public override async Task<int> SaveChangesAsync(
        CancellationToken cancellationToken = default)
    {
        // If a transaction is already open (caller-managed), just save normally.
        if (Database.CurrentTransaction is not null)
            return await base.SaveChangesAsync(cancellationToken);

        // CreateExecutionStrategy() is required when SqlServerRetryingExecutionStrategy
        // is configured — it does not support user-initiated transactions directly.
        var strategy = Database.CreateExecutionStrategy();

        return await strategy.ExecuteAsync(async () =>
        {
            await using IDbContextTransaction tx =
                await Database.BeginTransactionAsync(cancellationToken);
            try
            {
                int rows = await base.SaveChangesAsync(cancellationToken);
                await tx.CommitAsync(cancellationToken);
                return rows;
            }
            catch
            {
                await tx.RollbackAsync(cancellationToken);
                throw;
            }
        });
    }
}