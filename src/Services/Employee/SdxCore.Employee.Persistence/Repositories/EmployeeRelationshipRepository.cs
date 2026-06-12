using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Employee.Persistence.Repositories;

public class EmployeeRelationshipRepository 
    : BaseRepository<EmployeeRelationship, Guid, EmployeeDbContext>, IEmployeeRelationshipRepository
{
    public EmployeeRelationshipRepository(EmployeeDbContext dbContext)
        : base(dbContext)
    {
    }
}
