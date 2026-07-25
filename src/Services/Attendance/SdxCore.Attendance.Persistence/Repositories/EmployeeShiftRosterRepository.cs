using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class EmployeeShiftRosterRepository(AttendanceDbContext dbContext)
    : BaseRepository<EmployeeShiftRoster, Guid, AttendanceDbContext>(dbContext), IEmployeeShiftRosterRepository
{
    public async Task<EmployeeShiftRoster?> GetByEmployeeDateAsync(Guid employeeId, DateOnly date, CancellationToken cancellationToken = default)
        => await _dbSet
            .Include(r => r.Shift)
            .FirstOrDefaultAsync(r => r.EmployeeId == employeeId && r.RosterDate == date, cancellationToken);

    public async Task<IEnumerable<EmployeeShiftRoster>> GetByDateAsync(DateOnly date, CancellationToken cancellationToken = default)
        => await _dbSet
            .Include(r => r.Shift)
            .Where(r => r.RosterDate == date && r.IsActive)
            .ToListAsync(cancellationToken);

    public async Task<IEnumerable<EmployeeShiftRoster>> GetByEmployeeRangeAsync(Guid employeeId, DateOnly from, DateOnly to, CancellationToken cancellationToken = default)
        => await _dbSet
            .Include(r => r.Shift)
            .Where(r => r.EmployeeId == employeeId && r.RosterDate >= from && r.RosterDate <= to)
            .OrderBy(r => r.RosterDate)
            .ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<EmployeeShiftRoster>> GetPendingAttendanceCalculationAsync(
        DateTime dueAt, int batchSize, CancellationToken cancellationToken = default)
    {
        return await _dbContext.EmployeeShiftRosters
            .Where(r =>
                r.IsActive &&
                r.AttendanceCalculationDueAt <= dueAt)
            .Where(r =>
                !_dbContext.AttendanceRecords.Any(a =>
                    a.EmployeeId == r.EmployeeId &&
                    a.AttendanceDate == r.RosterDate))
            .Where(r =>
                !_dbContext.AttendanceCalculationQueues.Any(q =>
                    q.EmployeeId == r.EmployeeId &&
                    q.AttendanceDate == r.RosterDate &&
                    q.ProcessedAt == null))
            .OrderBy(r => r.AttendanceCalculationDueAt)
            .Take(batchSize)
            .ToListAsync(cancellationToken);
    }
}
