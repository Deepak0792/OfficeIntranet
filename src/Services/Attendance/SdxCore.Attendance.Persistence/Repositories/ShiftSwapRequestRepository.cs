using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class ShiftSwapRequestRepository(AttendanceDbContext dbContext)
    : BaseRepository<ShiftSwapRequest, Guid, AttendanceDbContext>(dbContext), IShiftSwapRequestRepository
{
    public async Task<IEnumerable<ShiftSwapRequest>> GetByEmployeeAsync(Guid employeeId, CancellationToken cancellationToken = default)
        => await _dbSet
            .Where(s => s.RequesterEmployeeId == employeeId || s.TargetEmployeeId == employeeId)
            .OrderByDescending(s => s.RequestedAt)
            .ToListAsync(cancellationToken);

    public async Task<ShiftSwapRequest?> GetByWorkflowInstanceIdAsync(Guid workflowInstanceId, CancellationToken cancellationToken = default)
        => await _dbSet.FirstOrDefaultAsync(s => s.WorkflowInstanceId == workflowInstanceId, cancellationToken);
}
