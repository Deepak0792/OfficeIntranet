using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.SharedKernel.Persistence.Outbox;

namespace SdxCore.Attendance.Persistence.Repositories;

public class OutboxRepository : OutboxRepository<AttendanceDbContext>, IOutboxRepository
{
    public OutboxRepository(AttendanceDbContext dbContext) : base(dbContext) { }
}
