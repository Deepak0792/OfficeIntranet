using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Interfaces;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class DesignationRepository : BaseRepository<Designation>, IDesignationRepository
{
    public DesignationRepository(TimeDbContext dbContext) : base(dbContext) { }
}
