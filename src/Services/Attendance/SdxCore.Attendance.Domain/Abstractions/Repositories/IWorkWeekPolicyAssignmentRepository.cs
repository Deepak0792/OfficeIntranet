using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IWorkWeekPolicyAssignmentRepository : IRepository<WorkWeekPolicyAssignment, Guid>
{
    Task<WorkWeekPolicyAssignment?> GetActiveForScopeAsync(Guid scopeTypeId, Guid? scopeReferenceId, DateOnly date, CancellationToken cancellationToken = default);
}
