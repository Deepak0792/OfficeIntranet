using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;
using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Employee.Persistence.Repositories;

public class EmployeeLocationRepository 
    : BaseRepository<EmployeeLocation, Guid, EmployeeDbContext>, IEmployeeLocationRepository
{
    public EmployeeLocationRepository(EmployeeDbContext dbContext) 
        : base(dbContext)
    {
    }
}
