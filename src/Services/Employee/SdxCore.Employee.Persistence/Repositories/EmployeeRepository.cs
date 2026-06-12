using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Employee.Persistence.Repositories;

public class EmployeeRepository 
    : BaseRepository<Domain.Entities.Employee, Guid, EmployeeDbContext>, IEmployeeRepository
{
    public EmployeeRepository(EmployeeDbContext dbContext)
        : base(dbContext)
    {
    }
}
