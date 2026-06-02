using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Repositories;
using SdxCore.Time.Persistence.Data;


namespace SdxCore.Time.Persistence.Repositories;

public class OfficeLocationRepository : BaseRepository<OfficeLocation, short, TimeDbContext>, IOfficeLocationRepository
{
    public OfficeLocationRepository(TimeDbContext dbContext, IRequestContext requestContext) : base(dbContext, requestContext) { }
}