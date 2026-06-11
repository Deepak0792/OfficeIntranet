using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Repositories;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class CountryRepository 
    : BaseRepository<Country, Guid,TimeDbContext>, ICountryRepository
{
    public CountryRepository(TimeDbContext dbContext) 
        : base(dbContext) { }
}

