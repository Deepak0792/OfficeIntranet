using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class OfficeLocationRepository : BaseRepository<OfficeLocation>, IOfficeLocationRepository
{
    public OfficeLocationRepository(TimeDbContext dbContext) : base(dbContext) { }
}
