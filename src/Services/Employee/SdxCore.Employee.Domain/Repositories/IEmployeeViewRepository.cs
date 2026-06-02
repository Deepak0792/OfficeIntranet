using SdxCore.Employee.Domain.Entities;
using System.Linq.Expressions;

namespace SdxCore.Employee.Domain.Repositories;

public interface IEmployeeViewRepository
{
    Task<EmployeeFullProfile?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<IEnumerable<EmployeeFullProfile>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<(IEnumerable<EmployeeFullProfile> Items, int TotalCount)> GetAllPagedAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<IEnumerable<EmployeeFullProfile>> FindAsync(Expression<Func<EmployeeFullProfile, bool>> predicate, CancellationToken cancellationToken = default);
}
