using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class CompOffBalanceRepository(AttendanceDbContext dbContext)
    : BaseRepository<CompOffBalance, Guid, AttendanceDbContext>(dbContext), ICompOffBalanceRepository
{
    public async Task<IEnumerable<CompOffBalance>> GetByEmployeeAsync(Guid employeeId, CancellationToken cancellationToken = default)
        => await _dbSet.Include(b => b.CompOffType)
            .Where(b => b.EmployeeId == employeeId && b.IsActive)
            .OrderByDescending(b => b.EarnedDate)
            .ToListAsync(cancellationToken);

    public async Task<CompOffBalance?> GetByWorkflowInstanceIdAsync(Guid workflowInstanceId, CancellationToken cancellationToken = default)
        => await _dbSet.FirstOrDefaultAsync(b => b.WorkflowInstanceId == workflowInstanceId, cancellationToken);
}
