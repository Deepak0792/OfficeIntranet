using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class GeoFenceRepository : BaseRepository<GeoFence>, IGeoFenceRepository
{
    public GeoFenceRepository(TimeDbContext dbContext) : base(dbContext) { }
}
