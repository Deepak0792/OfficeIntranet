using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IHolidayCalendarAssignmentRepository : IRepository<HolidayCalendarAssignment, Guid>
{
    Task<IEnumerable<HolidayCalendarAssignment>> GetActiveForScopeAsync(Guid scopeTypeId, Guid? scopeReferenceId, CancellationToken cancellationToken = default);
}
