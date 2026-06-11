using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Repositories;
using SdxCore.Time.Persistence.Data;


namespace SdxCore.Time.Persistence.Repositories;

public class DesignationRepository 
    : BaseRepository<Designation, Guid, TimeDbContext>, IDesignationRepository
{
    public DesignationRepository(TimeDbContext dbContext) 
        : base(dbContext) { }
}