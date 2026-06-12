using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Employee.Persistence.Repositories;

public class EmployeeContactRepository
    : BaseRepository<EmployeeContact, Guid, EmployeeDbContext>, IEmployeeContactRepository
{
    public EmployeeContactRepository(EmployeeDbContext dbContext)
        : base(dbContext)
    {
    }
}
