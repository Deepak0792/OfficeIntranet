using SdxCore.Common.Interfaces.Data;
using SdxCore.Employee.Domain.Entities;

namespace SdxCore.Employee.Domain.Interfaces.Repositories;

public interface IEmployeeRepository : IRepository<Domain.Entities.Employee, int>
{
}
