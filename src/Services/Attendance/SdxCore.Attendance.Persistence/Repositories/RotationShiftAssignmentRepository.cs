using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;
using Microsoft.EntityFrameworkCore;

namespace SdxCore.Attendance.Persistence.Repositories;

public class RotationShiftAssignmentRepository(AttendanceDbContext dbContext)
    : BaseRepository<RotationShiftAssignment, Guid, AttendanceDbContext>(dbContext), IRotationShiftAssignmentRepository
{
    public async Task<IEnumerable<RotationShiftAssignment>> GetActiveAssignmentsAsync(CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(a => a.RotationShift)
            .Where(a => a.IsActive)
            .OrderBy(a => a.PriorityOrder)
            .ToListAsync(cancellationToken);
    }
}
