using SdxCore.Employee.Domain;
using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Persistence;

namespace SdxCore.Employee.Persistence;

public sealed class EmployeeUnitOfWork : UnitOfWork<EmployeeDbContext>, IEmployeeUnitOfWork
{
    public EmployeeUnitOfWork(EmployeeDbContext dbContext) : base(dbContext) { }
}