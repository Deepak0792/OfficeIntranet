using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Time.Domain.Abstractions.Repositories;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class LegalEntityRepository 
    : BaseRepository<LegalEntity, Guid, TimeDbContext>, ILegalEntityRepository
{
    public LegalEntityRepository(TimeDbContext dbContext) 
        : base(dbContext) { }
}