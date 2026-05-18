using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class LegalEntityRepository : BaseRepository<LegalEntity>, ILegalEntityRepository
{
    public LegalEntityRepository(TimeDbContext dbContext) : base(dbContext) { }
}
