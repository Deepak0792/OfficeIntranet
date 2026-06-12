using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Employee.Persistence.Repositories;

public class TeamRepository 
    : BaseRepository<Team, Guid, EmployeeDbContext>, ITeamRepository
{
    public TeamRepository(EmployeeDbContext dbContext)
        : base(dbContext)
    {
    }
}
