using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.Common.Enums.Attendance;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class AttendanceRegularizationRepository(AttendanceDbContext dbContext)
    : BaseRepository<AttendanceRegularization, Guid, AttendanceDbContext>(dbContext), IAttendanceRegularizationRepository
{
    public async Task<AttendanceRegularization?> GetByWorkflowInstanceIdAsync(Guid workflowInstanceId, CancellationToken cancellationToken = default)
        => await _dbSet.FirstOrDefaultAsync(r => r.WorkflowInstanceId == workflowInstanceId, cancellationToken);

    public async Task<(IEnumerable<AttendanceRegularization> Items, int TotalCount)> GetPagedAsync(
        int page, int pageSize, Guid? employeeId, CancellationToken cancellationToken = default)
    {
        var query = _dbSet.AsQueryable();
        if (employeeId.HasValue) query = query.Where(r => r.EmployeeId == employeeId.Value);

        var total = await query.CountAsync(cancellationToken);
        var items = await query.OrderByDescending(r => r.CreatedAt)
            .Skip((page - 1) * pageSize).Take(pageSize)
            .ToListAsync(cancellationToken);
        return (items, total);
    }

    public async Task<AttendanceRegularization?> GetApprovedByEmployeeDateAsync(
        Guid employeeId,
        DateOnly attendanceDate,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet.FirstOrDefaultAsync(
                x =>
                    x.EmployeeId == employeeId
                    && x.AttendanceDate == attendanceDate
                    && x.RegularizationStatus == RegularizationStatus.Approved
                    && x.IsActive,
                cancellationToken);
    }
}
