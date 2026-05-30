using SdxCore.Common.Interfaces.Contexts;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Interfaces.Repositories;
using SdxCore.Employee.Persistence.Data;

namespace SdxCore.Employee.Persistence.Repositories;

public class EmployeeContactRepository : BaseRepository<EmployeeContact, int>, IEmployeeContactRepository
{
    public EmployeeContactRepository(EmployeeDbContext dbContext, IRequestContext requestContext) 
        : base(dbContext, requestContext)
    {
    }
}
