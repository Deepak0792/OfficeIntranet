using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class RosterGenerationPolicyAssignmentRepository(AttendanceDbContext dbContext)
    : BaseRepository<RosterGenerationPolicyAssignment, Guid, AttendanceDbContext>(dbContext),
      IRosterGenerationPolicyAssignmentRepository
{
    public async Task<IEnumerable<RosterGenerationPolicyAssignment>> GetByPolicyAsync(
        Guid policyId, CancellationToken cancellationToken = default)
        => await FindAsync(
            a => a.RosterGenerationPolicyId == policyId && a.IsActive,
            cancellationToken);

    public async Task<RosterGenerationPolicyAssignment?> ResolveAsync(
        Guid scopeTypeId, Guid? scopeReferenceId, DateOnly onDate,
        CancellationToken cancellationToken = default)
    {
        var results = await FindAsync(
            a => a.ScopeTypeId == scopeTypeId
              && a.ScopeReferenceId == scopeReferenceId
              && a.IsActive
              && a.EffectiveFrom <= onDate
              && (a.EffectiveTo == null || a.EffectiveTo >= onDate),
            cancellationToken);

        return results.OrderBy(a => a.PriorityOrder).FirstOrDefault();
    }
}
