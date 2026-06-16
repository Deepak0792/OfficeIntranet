using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class HolidayRepository(AttendanceDbContext dbContext)
    : BaseRepository<Holiday, Guid, AttendanceDbContext>(dbContext), IHolidayRepository
{
    public async Task<IEnumerable<Holiday>> GetByCalendarAsync(Guid calendarId, int year, CancellationToken cancellationToken = default)
        => await _dbSet
            .Where(h => h.HolidayCalendarId == calendarId && h.IsActive
                && (h.IsRecurring || h.ApplicableYear == null || h.ApplicableYear == year))
            .OrderBy(h => h.HolidayDate)
            .ToListAsync(cancellationToken);

    public async Task<IEnumerable<Holiday>> GetByCalendarRangeAsync(Guid calendarId, DateOnly from, DateOnly to, CancellationToken cancellationToken = default)
        => await _dbSet
            .Where(h => h.HolidayCalendarId == calendarId && h.IsActive && h.HolidayDate >= from && h.HolidayDate <= to)
            .OrderBy(h => h.HolidayDate)
            .ToListAsync(cancellationToken);
}
