using SdxCore.Common.Interfaces.Contexts;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces.Repositories;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class TimeZoneMasterRepository : BaseRepository<TimeZoneMaster, short>, ITimeZoneMasterRepository
{
    public TimeZoneMasterRepository(TimeDbContext dbContext, IRequestContext requestContext) : base(dbContext, requestContext) { }
}