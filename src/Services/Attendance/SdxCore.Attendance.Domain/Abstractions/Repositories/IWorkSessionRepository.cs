using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IWorkSessionRepository : IRepository<WorkSession, Guid>
{
    Task<WorkSession?> GetByRosterAsync(Guid rosterId, CancellationToken cancellationToken = default);
    Task<IReadOnlyCollection<WorkSession>> GetByEmployeeDateAsync(Guid employeeId, DateOnly date, CancellationToken cancellationToken = default);
}
