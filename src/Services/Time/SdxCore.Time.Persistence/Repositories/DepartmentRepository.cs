using SdxCore.SharedKernel.Persistence.Repositories;
using SdxCore.Time.Domain.Entities;
using SdxCore.Time.Domain.Repositories;
using SdxCore.Time.Persistence.Data;

namespace SdxCore.Time.Persistence.Repositories;

public class DepartmentRepository 
    : BaseRepository<Department, Guid,TimeDbContext>, IDepartmentRepository
{
    public DepartmentRepository(TimeDbContext dbContext) 
        : base(dbContext)
    {
    }
}