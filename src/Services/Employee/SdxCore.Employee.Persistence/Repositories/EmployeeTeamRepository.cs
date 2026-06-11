using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;
using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Employee.Persistence.Repositories;

public class EmployeeTeamRepository 
    : BaseRepository<EmployeeTeam, Guid, EmployeeDbContext>, IEmployeeTeamRepository
{
    public EmployeeTeamRepository(EmployeeDbContext dbContext)
        : base(dbContext)
    {
    }
}
