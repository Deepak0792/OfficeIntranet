using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class AttendanceRecordRepository(AttendanceDbContext dbContext)
    : BaseRepository<AttendanceRecord, Guid, AttendanceDbContext>(dbContext), IAttendanceRecordRepository
{
    public async Task<AttendanceRecord?> GetByEmployeeDateAsync(Guid employeeId, DateOnly date, CancellationToken cancellationToken = default)
        => await _dbSet
            .Include(r => r.Shift)
            .Include(r => r.AttendanceStatus)
            .FirstOrDefaultAsync(r => r.EmployeeId == employeeId && r.AttendanceDate == date, cancellationToken);

    public async Task<(IEnumerable<AttendanceRecord> Items, int TotalCount)> GetPagedAsync(
        int page, int pageSize, Guid? employeeId, DateOnly? from, DateOnly? to, CancellationToken cancellationToken = default)
    {
        var query = _dbSet.Include(r => r.AttendanceStatus).AsQueryable();
        if (employeeId.HasValue) query = query.Where(r => r.EmployeeId == employeeId.Value);
        if (from.HasValue) query = query.Where(r => r.AttendanceDate >= from.Value);
        if (to.HasValue) query = query.Where(r => r.AttendanceDate <= to.Value);

        var total = await query.CountAsync(cancellationToken);
        var items = await query.OrderByDescending(r => r.AttendanceDate)
            .Skip((page - 1) * pageSize).Take(pageSize)
            .ToListAsync(cancellationToken);
        return (items, total);
    }

    public async Task UpsertAsync(AttendanceRecord record, CancellationToken cancellationToken = default)
    {
        var existing = await GetByEmployeeDateAsync(record.EmployeeId, record.AttendanceDate, cancellationToken);
        if (existing is null)
            await _dbSet.AddAsync(record, cancellationToken);
        else
        {
            existing.AttendanceStatusId = record.AttendanceStatusId;
            existing.WorkedMinutes = record.WorkedMinutes;
            existing.LateByMinutes = record.LateByMinutes;
            existing.EarlyExitMinutes = record.EarlyExitMinutes;
            existing.OvertimeMinutes = record.OvertimeMinutes;
            existing.CheckInTime = record.CheckInTime;
            existing.CheckOutTime = record.CheckOutTime;
            existing.IsOnLeave = record.IsOnLeave;
            existing.IsAutoProcessed = record.IsAutoProcessed;
            existing.WorkSessionId = record.WorkSessionId;
            _dbSet.Update(existing);
        }
    }
}
