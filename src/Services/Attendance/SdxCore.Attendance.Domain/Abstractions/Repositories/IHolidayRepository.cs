using SdxCore.Attendance.Domain.Entities;
using SdxCore.SharedKernel.Abstractions.Repositories;

namespace SdxCore.Attendance.Domain.Abstractions.Repositories;

public interface IHolidayRepository : IRepository<Holiday, Guid>
{
    Task<IEnumerable<Holiday>> GetByCalendarAsync(Guid calendarId, int year, CancellationToken cancellationToken = default);
    Task<IEnumerable<Holiday>> GetByCalendarRangeAsync(Guid calendarId, DateOnly from, DateOnly to, CancellationToken cancellationToken = default);
}
