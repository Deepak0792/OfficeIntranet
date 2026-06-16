using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class WorkWeekPolicyRepository(AttendanceDbContext dbContext)
    : BaseRepository<WorkWeekPolicy, Guid, AttendanceDbContext>(dbContext), IWorkWeekPolicyRepository
{
    public async Task<WorkWeekPolicy?> GetWithDaysAsync(Guid id, CancellationToken cancellationToken = default)
        => await _dbSet
            .Include(p => p.Days.Where(d => d.IsActive).OrderBy(d => d.DayOfWeek))
            .FirstOrDefaultAsync(p => p.Id == id, cancellationToken);
}
