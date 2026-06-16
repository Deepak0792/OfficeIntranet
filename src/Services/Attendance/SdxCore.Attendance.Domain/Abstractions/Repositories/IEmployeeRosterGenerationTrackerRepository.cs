using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IEmployeeRosterGenerationTrackerRepository : IRepository<EmployeeRosterGenerationTracker, Guid>
{
    Task<EmployeeRosterGenerationTracker?> GetAsync(Guid employeeId, int year, int month, string generationType, CancellationToken cancellationToken = default);
    Task UpsertAsync(EmployeeRosterGenerationTracker tracker, CancellationToken cancellationToken = default);
}
