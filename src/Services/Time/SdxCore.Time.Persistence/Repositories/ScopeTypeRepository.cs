using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Repositories;
using SdxCore.Time.Persistence.Data;


namespace SdxCore.Time.Persistence.Repositories;

public class ScopeTypeRepository 
    : BaseRepository<ScopeType, Guid, TimeDbContext>, IScopeTypeRepository
{
    public ScopeTypeRepository(TimeDbContext dbContext) 
        : base(dbContext) { }
}