using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class RosterGenerationPolicyRepository(AttendanceDbContext dbContext)
    : BaseRepository<RosterGenerationPolicy, Guid, AttendanceDbContext>(dbContext),
      IRosterGenerationPolicyRepository
{
    public async Task<RosterGenerationPolicy?> GetDefaultAsync(CancellationToken cancellationToken = default)
    {
        var results = await FindAsync(p => p.IsDefault && p.IsActive, cancellationToken);
        return results.FirstOrDefault();
    }

    public async Task<RosterGenerationPolicy?> GetByCodeAsync(string policyCode, CancellationToken cancellationToken = default)
    {
        var results = await FindAsync(p => p.PolicyCode == policyCode, cancellationToken);
        return results.FirstOrDefault();
    }
}
