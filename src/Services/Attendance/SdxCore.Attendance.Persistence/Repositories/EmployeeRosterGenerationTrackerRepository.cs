using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class EmployeeRosterGenerationTrackerRepository(AttendanceDbContext dbContext)
    : BaseRepository<EmployeeRosterGenerationTracker, Guid, AttendanceDbContext>(dbContext), IEmployeeRosterGenerationTrackerRepository
{
    public async Task<EmployeeRosterGenerationTracker?> GetAsync(Guid employeeId, int year, int month, string generationType, CancellationToken cancellationToken = default)
        => await _dbSet.FirstOrDefaultAsync(
            t => t.EmployeeId == employeeId && t.RosterYear == year && t.RosterMonth == month && t.GenerationType == generationType,
            cancellationToken);

    public async Task UpsertAsync(EmployeeRosterGenerationTracker tracker, CancellationToken cancellationToken = default)
    {
        var existing = await GetAsync(tracker.EmployeeId, tracker.RosterYear, tracker.RosterMonth, tracker.GenerationType, cancellationToken);
        if (existing is null)
            await _dbSet.AddAsync(tracker, cancellationToken);
        else
        {
            existing.GeneratedFromDate = tracker.GeneratedFromDate;
            existing.GeneratedToDate = tracker.GeneratedToDate;
            existing.LastGeneratedAt = tracker.LastGeneratedAt;
            existing.IsLocked = tracker.IsLocked;
            existing.Remarks = tracker.Remarks;
            _dbSet.Update(existing);
        }
    }

    public async Task<IReadOnlyCollection<EmployeeRosterGenerationTracker>> GetByEmployeeAsync(
        Guid employeeId,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(x => x.EmployeeId == employeeId && x.IsActive)
            .ToListAsync(cancellationToken);
    }
}
