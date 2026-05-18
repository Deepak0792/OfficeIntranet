using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class TimeZoneMasterRepository : BaseRepository<TimeZoneMaster>, ITimeZoneMasterRepository
{
    public TimeZoneMasterRepository(TimeDbContext dbContext) : base(dbContext) { }
}
