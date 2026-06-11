using Microsoft.EntityFrameworkCore;
using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SdxCore.SharedKernel.Persistence;

// SdxCore.SharedKernel.Persistence
public abstract class UnitOfWork<TDbContext> : IUnitOfWork
    where TDbContext : DbContext
{
    protected readonly TDbContext DbContext;

    protected UnitOfWork(TDbContext dbContext)
    {
        DbContext = dbContext;
    }

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        => DbContext.SaveChangesAsync(cancellationToken);

    public ValueTask DisposeAsync()
        => DbContext.DisposeAsync();
}