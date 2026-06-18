using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class HolidayCalendarAssignmentRepository(AttendanceDbContext dbContext)
    : BaseRepository<HolidayCalendarAssignment, Guid, AttendanceDbContext>(dbContext), IHolidayCalendarAssignmentRepository
{
    public async Task<IEnumerable<HolidayCalendarAssignment>> GetActiveForScopeAsync(
        Guid scopeTypeId, Guid? scopeReferenceId, CancellationToken cancellationToken = default)
        => await _dbSet
            .Include(a => a.HolidayCalendar)
            .Where(a => a.ScopeTypeId == scopeTypeId && a.ScopeReferenceId == scopeReferenceId && a.IsActive)
            .OrderBy(a => a.PriorityOrder)
            .ToListAsync(cancellationToken);

    public async Task<IEnumerable<HolidayCalendarAssignment>> GetActiveAssignmentsAsync(
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(a => a.HolidayCalendar)
            .Where(a => a.IsActive)
            .OrderBy(a => a.PriorityOrder)
            .ToListAsync(cancellationToken);
    }
}
