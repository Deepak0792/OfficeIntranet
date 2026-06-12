using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Employee.Domain.Abstractions.Repositories;

public interface IEmployeeRepository : IRepository<Entities.Employee, Guid>
{
}
