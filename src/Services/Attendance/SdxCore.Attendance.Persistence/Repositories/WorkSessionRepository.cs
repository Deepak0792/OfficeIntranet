using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class WorkSessionRepository(AttendanceDbContext dbContext)
    : BaseRepository<WorkSession, Guid, AttendanceDbContext>(dbContext), IWorkSessionRepository
{
    public async Task<WorkSession?> GetByRosterAsync(Guid rosterId, CancellationToken cancellationToken = default)
        => await _dbSet.FirstOrDefaultAsync(w => w.EmployeeShiftRosterId == rosterId, cancellationToken);

    public async Task<IReadOnlyCollection<WorkSession>> GetByEmployeeDateAsync(Guid employeeId, DateOnly date, CancellationToken cancellationToken = default)
    {
        var sessions =
            await _dbSet
                .AsNoTracking()
                .Where(w => w.EmployeeId == employeeId && w.SessionDate == date)
                .ToListAsync(cancellationToken);

        return sessions;
    }

    public async Task<WorkSession?> GetActiveSessionAsync(Guid employeeId, CancellationToken cancellationToken = default)
    {
        return await _dbSet.Where(w => w.EmployeeId == employeeId && w.IsActive && w.CheckOutTime == null)
            .OrderByDescending(w => w.CheckInTime)
            .FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<IReadOnlyCollection<WorkSession>> GetDueForAutoCheckoutAsync(
        DateTime utcNow,
        int batchSize,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(x => x.IsActive && !x.AutoCheckoutProcessed && x.CheckOutTime == null
                && x.AutoCheckoutDueAt != null && x.AutoCheckoutDueAt <= utcNow)
            .OrderBy(x => x.AutoCheckoutDueAt)
            .Take(batchSize)
            .ToListAsync(cancellationToken);
    }
}
