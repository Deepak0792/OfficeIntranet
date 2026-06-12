using SdxCore.SharedKernel.Abstractions.Repositories;
using SdxCore.Time.Domain.Entities;

namespace SdxCore.Time.Domain.Abstractions.Repositories;

public interface IDepartmentRepository : IRepository<Department, Guid>
{
    // Add specific department methods here if needed in the future
}

