using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Repositories;
using SdxCore.Time.Persistence.Data;


namespace SdxCore.Time.Persistence.Repositories;

public class GeoFenceRepository : BaseRepository<GeoFence, Guid, TimeDbContext>, IGeoFenceRepository
{
    public GeoFenceRepository(TimeDbContext dbContext, IUserContext requestContext) : base(dbContext, requestContext) { }
}