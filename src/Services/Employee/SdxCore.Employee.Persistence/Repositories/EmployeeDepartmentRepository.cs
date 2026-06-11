using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;
using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Employee.Persistence.Repositories;

public class EmployeeDepartmentRepository 
    : BaseRepository<EmployeeDepartment, Guid, EmployeeDbContext>, IEmployeeDepartmentRepository
{
    public EmployeeDepartmentRepository(EmployeeDbContext dbContext) 
        : base(dbContext)
    {
    }
}
