using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Employee.Persistence.Repositories;

public class EmployeeBiometricMappingRepository :
    BaseRepository<EmployeeBiometricMapping, Guid, EmployeeDbContext>,
    IEmployeeBiometricMappingRepository
{
    public EmployeeBiometricMappingRepository(EmployeeDbContext dbContext)
        : base(dbContext)
    {
    }
}
