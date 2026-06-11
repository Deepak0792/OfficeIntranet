using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Repositories;
using SdxCore.Time.Persistence.Data;


namespace SdxCore.Time.Persistence.Repositories;

public class TimeZoneMasterRepository
    : BaseRepository<TimeZoneMaster, Guid, TimeDbContext>, ITimeZoneMasterRepository
{
    public TimeZoneMasterRepository(TimeDbContext dbContext)
        : base(dbContext) { }
}