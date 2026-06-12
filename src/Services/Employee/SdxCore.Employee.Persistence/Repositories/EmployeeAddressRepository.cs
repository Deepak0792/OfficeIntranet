using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Employee.Persistence.Repositories;

public class EmployeeAddressRepository
    : BaseRepository<EmployeeAddress, Guid, EmployeeDbContext>, IEmployeeAddressRepository
{
    public EmployeeAddressRepository(EmployeeDbContext dbContext)
        : base(dbContext)
    {
    }
}
