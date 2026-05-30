using SdxCore.Common.Interfaces.Contexts;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Interfaces.Repositories;
using SdxCore.Employee.Persistence.Data;

namespace SdxCore.Employee.Persistence.Repositories;

public class SkillRepository : BaseRepository<Skill, short>, ISkillRepository
{
    public SkillRepository(EmployeeDbContext dbContext, IRequestContext requestContext)
        : base(dbContext, requestContext)
    {
    }
}
