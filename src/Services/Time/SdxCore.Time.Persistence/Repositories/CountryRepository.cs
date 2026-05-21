using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces.Repositories;
using SdxCore.Time.Persistence.Data;
using SdxCore.Common.Interfaces.Contexts;

namespace SdxCore.Time.Persistence.Repositories;

public class CountryRepository : BaseRepository<Country, short>, ICountryRepository
{
    public CountryRepository(TimeDbContext dbContext, IRequestContext requestContext) : base(dbContext, requestContext) { }
}

