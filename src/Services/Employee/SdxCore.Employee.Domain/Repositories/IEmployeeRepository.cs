using SdxCore.SharedKernel.Persistence.Repositories.Contracts;

namespace SdxCore.Employee.Domain.Repositories;

public interface IEmployeeRepository : IRepository<Entities.Employee, Guid>
{
}
