using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IRosterGenerationPolicyAssignmentRepository : IRepository<RosterGenerationPolicyAssignment, Guid>
{
    /// <summary>
    /// Returns all active assignments for a given policy, ordered by PriorityOrder ascending.
    /// </summary>
    Task<IEnumerable<RosterGenerationPolicyAssignment>> GetByPolicyAsync(
        Guid policyId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Resolves the effective assignment for a specific scope reference on a given date.
    /// Returns the highest-priority (lowest PriorityOrder) active assignment.
    /// </summary>
    Task<RosterGenerationPolicyAssignment?> ResolveAsync(
        Guid scopeTypeId, Guid? scopeReferenceId, DateOnly onDate,
        CancellationToken cancellationToken = default);
}
