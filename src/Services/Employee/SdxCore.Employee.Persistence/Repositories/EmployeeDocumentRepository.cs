using SdxCore.Employee.Domain.Abstractions.Repositories;
using SdxCore.Employee.Domain.Entities;
using SdxCore.Employee.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Employee.Persistence.Repositories;

public class EmployeeDocumentRepository 
    : BaseRepository<EmployeeDocument, Guid, EmployeeDbContext>, IEmployeeDocumentRepository
{
    public EmployeeDocumentRepository(EmployeeDbContext dbContext) 
        : base(dbContext)
    {
    }
}
