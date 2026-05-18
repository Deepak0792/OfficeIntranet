using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class RegionRepository : BaseRepository<Region>, IRegionRepository
{
    public RegionRepository(TimeDbContext dbContext) : base(dbContext) { }
}
