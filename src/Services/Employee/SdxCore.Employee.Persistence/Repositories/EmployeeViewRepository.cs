using Microsoft.EntityFrameworkCore;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;
using SdxCore.Employee.Persistence.Data;
using System.Linq.Expressions;

namespace SdxCore.Employee.Persistence.Repositories;

public class EmployeeViewRepository : IEmployeeViewRepository
{
    private readonly EmployeeDbContext _dbContext;

    public EmployeeViewRepository(EmployeeDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<EmployeeSummary?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _dbContext.EmployeeFullProfiles
            .FirstOrDefaultAsync(e => e.EmployeeId == id, cancellationToken);
    }

    public async Task<IEnumerable<EmployeeSummary>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _dbContext.EmployeeFullProfiles.AsNoTracking().ToListAsync(cancellationToken);
    }

    public async Task<(IEnumerable<EmployeeSummary> Items, int TotalCount)> GetAllPagedAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        var query = _dbContext.EmployeeFullProfiles.AsNoTracking();
        var count = await query.CountAsync(cancellationToken);
        var items = await query.Skip((pageNumber - 1) * pageSize).Take(pageSize).ToListAsync(cancellationToken);
        return (items, count);
    }

    public async Task<IEnumerable<EmployeeSummary>> FindAsync(Expression<Func<EmployeeSummary, bool>> predicate, CancellationToken cancellationToken = default)
    {
        return await _dbContext.EmployeeFullProfiles.AsNoTracking().Where(predicate).ToListAsync(cancellationToken);
    }
}
