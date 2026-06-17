using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IRosterGenerationPolicyRepository : IRepository<RosterGenerationPolicy, Guid>
{
    Task<RosterGenerationPolicy?> GetDefaultAsync(CancellationToken cancellationToken = default);
    Task<RosterGenerationPolicy?> GetByCodeAsync(string policyCode, CancellationToken cancellationToken = default);
}
