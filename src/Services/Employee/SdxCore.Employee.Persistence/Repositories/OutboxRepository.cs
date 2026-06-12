using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.SharedKernel.Persistence.Outbox;

namespace SdxCore.Employee.Persistence.Repositories;

public class OutboxRepository : OutboxRepository<EmployeeDbContext>, IOutboxRepository
{
    public OutboxRepository(
        EmployeeDbContext dbContext)
        : base(dbContext)
    {
    }
}

