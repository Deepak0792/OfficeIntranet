using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class ShiftAssignmentRepository(AttendanceDbContext dbContext)
    : BaseRepository<ShiftAssignment, Guid, AttendanceDbContext>(dbContext), IShiftAssignmentRepository
{
    public async Task<IEnumerable<ShiftAssignment>> GetActiveAssignmentsAsync(CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(a => a.Shift)
            .Where(a => a.IsActive)
            .OrderBy(a => a.PriorityOrder)
            .ToListAsync(cancellationToken);
    }
}
