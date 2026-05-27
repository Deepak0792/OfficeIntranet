using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Interfaces.Repositories;
using SdxCore.Employee.Persistence.Data;

namespace SdxCore.Employee.Persistence.Repositories;

public class EmployeeRepository : BaseRepository<Employee>, IEmployeeRepository
{
    public EmployeeRepository(EmployeeDbContext context) : base(context) { }
}

public class EmployeeLegalEntityRepository : BaseRepository<EmployeeLegalEntity>, IEmployeeLegalEntityRepository
{
    public EmployeeLegalEntityRepository(EmployeeDbContext context) : base(context) { }
}

public class EmployeeDepartmentRepository : BaseRepository<EmployeeDepartment>, IEmployeeDepartmentRepository
{
    public EmployeeDepartmentRepository(EmployeeDbContext context) : base(context) { }
}
