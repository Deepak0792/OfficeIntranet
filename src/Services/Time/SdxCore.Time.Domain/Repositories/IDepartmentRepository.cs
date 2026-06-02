using SdxCore.SharedKernel.Persistence.Repositories.Contracts;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Domain.Repositories;

public interface IDepartmentRepository : IRepository<Department, short>
{
    // Add specific department methods here if needed in the future
}

