using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class LeaveRequestRepository(AttendanceDbContext dbContext)
    : BaseRepository<LeaveRequest, Guid, AttendanceDbContext>(dbContext), ILeaveRequestRepository
{
    public async Task<LeaveRequest?> GetByWorkflowInstanceIdAsync(Guid workflowInstanceId, CancellationToken cancellationToken = default)
        => await _dbSet.Include(r => r.LeaveType)
            .FirstOrDefaultAsync(r => r.WorkflowInstanceId == workflowInstanceId, cancellationToken);

    public async Task<IEnumerable<LeaveRequest>> GetByEmployeeAsync(Guid employeeId, CancellationToken cancellationToken = default)
        => await _dbSet.Include(r => r.LeaveType)
            .Where(r => r.EmployeeId == employeeId)
            .OrderByDescending(r => r.FromDate)
            .ToListAsync(cancellationToken);

    public async Task<LeaveRequest?> GetApprovedLeaveForDateAsync(Guid employeeId, DateOnly date, CancellationToken cancellationToken = default)
        => await _dbSet.FirstOrDefaultAsync(
            r => r.EmployeeId == employeeId
              && r.LeaveStatus == Common.Enums.Attendance.LeaveStatus.Approved
              && r.FromDate <= date
              && r.ToDate >= date,
            cancellationToken);

    public async Task<(IEnumerable<LeaveRequest> Items, int TotalCount)> GetPagedAsync(
        int page, int pageSize, Guid? employeeId, string? status, CancellationToken cancellationToken = default)
    {
        var query = _dbSet.Include(r => r.LeaveType).AsQueryable();
        if (employeeId.HasValue) query = query.Where(r => r.EmployeeId == employeeId.Value);
        if (!string.IsNullOrEmpty(status)) query = query.Where(r => r.LeaveStatus == status);

        var total = await query.CountAsync(cancellationToken);
        var items = await query.OrderByDescending(r => r.CreatedAt)
            .Skip((page - 1) * pageSize).Take(pageSize)
            .ToListAsync(cancellationToken);
        return (items, total);
    }
}
