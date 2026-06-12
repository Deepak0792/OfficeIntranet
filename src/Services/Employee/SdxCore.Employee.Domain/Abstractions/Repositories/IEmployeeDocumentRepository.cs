using SdxCore.Employee.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Employee.Domain.Abstractions.Repositories;

public interface IEmployeeDocumentRepository : IRepository<EmployeeDocument, Guid>
{
}
