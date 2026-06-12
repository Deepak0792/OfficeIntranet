using SdxCore.SharedKernel.Persistence;
using SdxCore.Time.Domain.Abstractions;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence;


public sealed class TimeUnitOfWork : UnitOfWork<TimeDbContext>, ITimeUnitOfWork
{
    public TimeUnitOfWork(TimeDbContext dbContext) : base(dbContext) { }
}