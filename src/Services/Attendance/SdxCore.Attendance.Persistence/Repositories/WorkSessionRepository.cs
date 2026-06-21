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
}
