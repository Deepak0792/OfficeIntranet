$domainDir = "d:\Office\SdxCore\src\Services\Employee\SdxCore.Employee.Domain\Interfaces\Repositories"
$persistenceDir = "d:\Office\SdxCore\src\Services\Employee\SdxCore.Employee.Persistence\Repositories"

New-Item -ItemType Directory -Force -Path $domainDir | Out-Null
New-Item -ItemType Directory -Force -Path $persistenceDir | Out-Null

$baseRepoCode = @"
using System;
using System.Collections.Generic;
using System.Linq.Expressions;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Employee.Domain.Entities;

namespace SdxCore.Employee.Domain.Interfaces.Repositories;

public interface IBaseRepository<TEntity> where TEntity : BaseEntity
{
    Task<TEntity?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<IEnumerable<TEntity>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<IEnumerable<TEntity>> FindAsync(Expression<Func<TEntity, bool>> predicate, CancellationToken cancellationToken = default);
    Task AddAsync(TEntity entity, CancellationToken cancellationToken = default);
    void Update(TEntity entity);
    void Remove(TEntity entity);
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
"@
Set-Content -Path "$domainDir\IBaseRepository.cs" -Value $baseRepoCode

$employeeRepoIfc = @"
using SdxCore.Employee.Domain.Entities;

namespace SdxCore.Employee.Domain.Interfaces.Repositories;

public interface IEmployeeRepository : IBaseRepository<Employee> { }
public interface IEmployeeLegalEntityRepository : IBaseRepository<EmployeeLegalEntity> { }
public interface IEmployeeDepartmentRepository : IBaseRepository<EmployeeDepartment> { }
"@
Set-Content -Path "$domainDir\IEmployeeRepository.cs" -Value $employeeRepoIfc

$baseRepoImplCode = @"
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Interfaces.Repositories;
using SdxCore.Employee.Persistence.Data;

namespace SdxCore.Employee.Persistence.Repositories;

public class BaseRepository<TEntity> : IBaseRepository<TEntity> where TEntity : BaseEntity
{
    protected readonly EmployeeDbContext _context;
    
    public BaseRepository(EmployeeDbContext context)
    {
        _context = context;
    }

    public async Task<TEntity?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return await _context.Set<TEntity>().FindAsync(new object[] { id }, cancellationToken);
    }

    public async Task<IEnumerable<TEntity>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _context.Set<TEntity>().ToListAsync(cancellationToken);
    }

    public async Task<IEnumerable<TEntity>> FindAsync(Expression<Func<TEntity, bool>> predicate, CancellationToken cancellationToken = default)
    {
        return await _context.Set<TEntity>().Where(predicate).ToListAsync(cancellationToken);
    }

    public async Task AddAsync(TEntity entity, CancellationToken cancellationToken = default)
    {
        await _context.Set<TEntity>().AddAsync(entity, cancellationToken);
    }

    public void Update(TEntity entity)
    {
        _context.Set<TEntity>().Update(entity);
    }

    public void Remove(TEntity entity)
    {
        _context.Set<TEntity>().Remove(entity);
    }

    public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return await _context.SaveChangesAsync(cancellationToken);
    }
}
"@
Set-Content -Path "$persistenceDir\BaseRepository.cs" -Value $baseRepoImplCode

$employeeRepoImpl = @"
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
"@
Set-Content -Path "$persistenceDir\EmployeeRepository.cs" -Value $employeeRepoImpl

Write-Output "Generated Repositories."
