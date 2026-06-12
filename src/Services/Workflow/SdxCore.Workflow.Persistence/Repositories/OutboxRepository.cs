using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.SharedKernel.Persistence.Outbox;
using SdxCore.Workflow.Persistence.Data;

namespace SdxCore.Workflow.Persistence.Repositories;

public class OutboxRepository 
    : OutboxRepository<WorkflowDbContext>, IOutboxRepository
{
    public OutboxRepository(
        WorkflowDbContext dbContext)
        : base(dbContext)
    {
    }
}

