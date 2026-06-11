using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Repositories;
using SdxCore.Time.Persistence.Data;


namespace SdxCore.Time.Persistence.Repositories;

public class RegionRepository 
    : BaseRepository<Region, Guid, TimeDbContext>, IRegionRepository
{
    public RegionRepository(TimeDbContext dbContext) 
        : base(dbContext) { }
}