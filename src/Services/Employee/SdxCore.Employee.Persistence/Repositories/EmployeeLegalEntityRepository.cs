using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Employee.Persistence.Repositories;

public class EmployeeLegalEntityRepository 
    : BaseRepository<EmployeeLegalEntity, Guid, EmployeeDbContext>, IEmployeeLegalEntityRepository
{
    public EmployeeLegalEntityRepository(EmployeeDbContext dbContext) 
        : base(dbContext)
    {
    }
}
