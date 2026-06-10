using SdxCore.Employee.Domain.Entities;
using System.Linq.Expressions;

namespace SdxCore.Employee.Domain.Repositories;

public interface IEmployeeViewRepository
{
    Task<EmployeeSummary?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<EmployeeSummary>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<(IEnumerable<EmployeeSummary> Items, int TotalCount)> GetAllPagedAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<IEnumerable<EmployeeSummary>> FindAsync(Expression<Func<EmployeeSummary, bool>> predicate, CancellationToken cancellationToken = default);
}
