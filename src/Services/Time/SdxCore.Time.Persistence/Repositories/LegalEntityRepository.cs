using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Repositories;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class LegalEntityRepository : BaseRepository<LegalEntity, short, TimeDbContext>, ILegalEntityRepository
{
    public LegalEntityRepository(TimeDbContext dbContext, IRequestContext requestContext) : base(dbContext, requestContext) { }
}