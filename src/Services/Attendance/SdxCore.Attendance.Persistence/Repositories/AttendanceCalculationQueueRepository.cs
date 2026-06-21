using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class AttendanceCalculationQueueRepository(
    AttendanceDbContext dbContext)
    : BaseRepository<
        AttendanceCalculationQueue,
        Guid,
        AttendanceDbContext>(dbContext),
      IAttendanceCalculationQueueRepository
{
    public async Task<AttendanceCalculationQueue?> GetAsync(
        Guid employeeId,
        DateOnly attendanceDate,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet.FirstOrDefaultAsync(
            x => x.EmployeeId == employeeId
              && x.AttendanceDate == attendanceDate
              && x.IsActive,
            cancellationToken);
    }

    public async Task<List<AttendanceCalculationQueue>>
        GetPendingAsync(
            int batchSize,
            CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(x =>
                x.IsActive &&
                x.ProcessedAt == null)
            .OrderByDescending(x => x.Priority)
            .ThenBy(x => x.CreatedAt)
            .Take(batchSize)
            .ToListAsync(cancellationToken);
    }
}