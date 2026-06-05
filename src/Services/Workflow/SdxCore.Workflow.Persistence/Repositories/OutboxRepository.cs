using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Persistence.Outbox;
using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Workflow.Persistence.Data;

namespace SdxCore.Workflow.Persistence.Repositories;

public class OutboxRepository : OutboxRepository<WorkflowDbContext>, IOutboxRepository
{
    public OutboxRepository(
        WorkflowDbContext dbContext,
        IRequestContext requestContext)
        : base(dbContext, requestContext)
    {
    }
}

