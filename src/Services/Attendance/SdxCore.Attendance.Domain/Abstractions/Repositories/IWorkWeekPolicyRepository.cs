using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IWorkWeekPolicyRepository : IRepository<WorkWeekPolicy, Guid>
{
    Task<WorkWeekPolicy?> GetWithDaysAsync(Guid id, CancellationToken cancellationToken = default);
}
