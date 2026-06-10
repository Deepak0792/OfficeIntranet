using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Domain.Repositories;
using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Contracts;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Employee.Persistence.Repositories;

public class EmployeeBiometricMappingRepository : 
    BaseRepository<EmployeeBiometricMapping, Guid, EmployeeDbContext>,
    IEmployeeBiometricMappingRepository
{
    public EmployeeBiometricMappingRepository(EmployeeDbContext dbContext, IUserContext requestContext)
        : base(dbContext, requestContext)
    {
    }
}
