using System;
using System.Collections.Generic;
using System.Linq.Expressions;
using System.Threading;
using System.Threading.Tasks;
using SdxCore.Employee.Domain.Entities;

namespace SdxCore.Employee.Domain.Interfaces.Repositories;

public interface IEmployeeViewRepository
{
    Task<EmployeeFullProfile?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<IEnumerable<EmployeeFullProfile>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<(IEnumerable<EmployeeFullProfile> Items, int TotalCount)> GetAllPagedAsync(int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<IEnumerable<EmployeeFullProfile>> FindAsync(Expression<Func<EmployeeFullProfile, bool>> predicate, CancellationToken cancellationToken = default);
}
