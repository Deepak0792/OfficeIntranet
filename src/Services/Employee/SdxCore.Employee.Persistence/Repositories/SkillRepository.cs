using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Employee.Persistence.Repositories;

public class SkillRepository 
    : BaseRepository<Skill, Guid, EmployeeDbContext>, ISkillRepository
{
    public SkillRepository(EmployeeDbContext dbContext)
        : base(dbContext)
    {
    }
}
