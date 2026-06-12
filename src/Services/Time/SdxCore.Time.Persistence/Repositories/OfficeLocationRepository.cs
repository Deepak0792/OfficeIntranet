using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Time.Domain.Abstractions.Repositories;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Persistence.Data;


namespace SdxCore.Time.Persistence.Repositories;

public class OfficeLocationRepository 
    : BaseRepository<OfficeLocation, Guid, TimeDbContext>, IOfficeLocationRepository
{
    public OfficeLocationRepository(TimeDbContext dbContext) 
        : base(dbContext) { }
}