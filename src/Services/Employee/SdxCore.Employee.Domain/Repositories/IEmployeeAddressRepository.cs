using SdxCore.Employee.Domain.Entities;
using SdxCore.SharedKernel.Persistence.Repositories.Contracts;

namespace SdxCore.Employee.Domain.Repositories;

public interface IEmployeeAddressRepository : IRepository<EmployeeAddress, Guid>
{
}
