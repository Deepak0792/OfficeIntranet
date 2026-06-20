using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class CompOffAvailmentRepository(
    AttendanceDbContext dbContext)
    : BaseRepository<CompOffAvailment, Guid, AttendanceDbContext>(dbContext),
      ICompOffAvailmentRepository
{
    public async Task<IReadOnlyList<CompOffAvailment>>
        GetByLeaveRequestIdAsync(
            Guid leaveRequestId,
            CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(x =>
                x.LeaveRequestId == leaveRequestId &&
                x.IsActive)
            .Include(x => x.CompOffBalance)
            .OrderBy(x => x.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<CompOffAvailment>>
        GetByCompOffBalanceIdAsync(
            Guid compOffBalanceId,
            CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(x =>
                x.CompOffBalanceId == compOffBalanceId &&
                x.IsActive)
            .Include(x => x.LeaveRequest)
            .OrderBy(x => x.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<decimal>
        GetTotalAvailedDaysAsync(
            Guid compOffBalanceId,
            CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(x =>
                x.CompOffBalanceId == compOffBalanceId &&
                x.IsActive)
            .SumAsync(
                x => (decimal?)x.DaysAvailed,
                cancellationToken) ?? 0;
    }
}