using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class WorkWeekPolicyAssignmentRepository(AttendanceDbContext dbContext)
    : BaseRepository<WorkWeekPolicyAssignment, Guid, AttendanceDbContext>(dbContext), IWorkWeekPolicyAssignmentRepository
{
    public async Task<WorkWeekPolicyAssignment?> GetActiveForScopeAsync(
        Guid scopeTypeId, Guid? scopeReferenceId, DateOnly date, CancellationToken cancellationToken = default)
        => await _dbSet
            .Where(a => a.ScopeTypeId == scopeTypeId
                && a.ScopeReferenceId == scopeReferenceId
                && a.IsActive
                && a.EffectiveFrom <= date
                && (a.EffectiveTo == null || a.EffectiveTo >= date))
            .OrderByDescending(a => a.PriorityOrder)
            .FirstOrDefaultAsync(cancellationToken);

    public async Task<IEnumerable<WorkWeekPolicyAssignment>> GetActiveAssignmentsAsync(
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(a => a.IsActive)
            .OrderBy(a => a.PriorityOrder)
            .ToListAsync(cancellationToken);
    }
}
