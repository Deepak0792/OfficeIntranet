using SdxCore.Common.Interfaces.Contexts;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces.Repositories;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class ScopeTypeRepository : BaseRepository<ScopeType>, IScopeTypeRepository
{
    public ScopeTypeRepository(TimeDbContext dbContext, IRequestContext requestContext) : base(dbContext, requestContext) { }
}