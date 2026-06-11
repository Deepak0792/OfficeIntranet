using SdxCore.SharedKernel.Persistence.Outbox;
using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class OutboxRepository 
    : OutboxRepository<TimeDbContext>, IOutboxRepository
{
    public OutboxRepository(
        TimeDbContext dbContext)
        : base(dbContext)
    {
    }
}

