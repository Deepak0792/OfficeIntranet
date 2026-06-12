using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Employee.Persistence.Repositories;

public class EmployeeSkillRepository 
    : BaseRepository<EmployeeSkill, Guid, EmployeeDbContext>, IEmployeeSkillRepository
{
    public EmployeeSkillRepository(EmployeeDbContext dbContext)
        : base(dbContext)
    {
    }
}
