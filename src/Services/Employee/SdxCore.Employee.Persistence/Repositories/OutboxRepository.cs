using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Persistence.Outbox;
using SdxCore.SharedKernel.Persistence.Repositories.Contracts;

namespace SdxCore.Employee.Persistence.Repositories;

public class OutboxRepository : OutboxRepository<EmployeeDbContext>, IOutboxRepository
{
    public OutboxRepository(
        EmployeeDbContext dbContext,
        IUserContext requestContext)
        : base(dbContext, requestContext)
    {
    }
}

