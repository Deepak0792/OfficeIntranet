using SdxCore.Common.Interfaces.Contexts;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Interfaces.Repositories;
using SdxCore.Employee.Persistence.Data;

namespace SdxCore.Employee.Persistence.Repositories;

public class EmployeeAddressRepository : BaseRepository<EmployeeAddress, int>, IEmployeeAddressRepository
{
    public EmployeeAddressRepository(EmployeeDbContext dbContext, IRequestContext requestContext) 
        : base(dbContext, requestContext)
    {
    }
}
