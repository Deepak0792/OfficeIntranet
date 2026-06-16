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
}
