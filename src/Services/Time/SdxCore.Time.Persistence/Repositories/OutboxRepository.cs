using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.SharedKernel.Persistence.Outbox;
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

