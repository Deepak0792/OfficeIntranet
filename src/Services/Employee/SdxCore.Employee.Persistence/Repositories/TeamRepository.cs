using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;
using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Employee.Persistence.Repositories;

public class TeamRepository : BaseRepository<Team, Guid, EmployeeDbContext>, ITeamRepository
{
    public TeamRepository(EmployeeDbContext dbContext, IUserContext requestContext)
        : base(dbContext, requestContext)
    {
    }
}
