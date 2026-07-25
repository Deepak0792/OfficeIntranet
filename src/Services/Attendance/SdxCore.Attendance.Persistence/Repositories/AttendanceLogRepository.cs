using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class AttendanceLogRepository(AttendanceDbContext dbContext)
    : BaseRepository<AttendanceLog, Guid, AttendanceDbContext>(dbContext), IAttendanceLogRepository
{
    public async Task<IReadOnlyList<AttendanceLog>> GetPendingLogsAsync(
        int batchSize,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(x =>
                !x.IsProcessed &&
                x.IsActive)
            .OrderBy(x => x.PunchTime)
            .ThenBy(x => x.CreatedAt)
            .Take(batchSize)
            .ToListAsync(cancellationToken);
    }
}
