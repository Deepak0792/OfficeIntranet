using Microsoft.EntityFrameworkCore;
using SdxCore.Attendance.Domain.Abstractions.Repositories;
using SdxCore.Attendance.Domain.Entities;
using SdxCore.Attendance.Persistence.Data;
using SdxCore.SharedKernel.Persistence.Repositories;

namespace SdxCore.Attendance.Persistence.Repositories;

public class LeaveBalanceRepository(AttendanceDbContext dbContext)
    : BaseRepository<LeaveBalance, Guid, AttendanceDbContext>(dbContext), ILeaveBalanceRepository
{
    public async Task<IEnumerable<LeaveBalance>> GetByEmployeeAsync(Guid employeeId, int year, CancellationToken cancellationToken = default)
        => await _dbSet.Include(b => b.LeaveType)
            .Where(b => b.EmployeeId == employeeId && b.BalanceYear == year)
            .ToListAsync(cancellationToken);

    public async Task<LeaveBalance?> GetByEmployeeAndTypeAsync(Guid employeeId, Guid leaveTypeId, int year, CancellationToken cancellationToken = default)
        => await _dbSet.FirstOrDefaultAsync(
            b => b.EmployeeId == employeeId && b.LeaveTypeId == leaveTypeId && b.BalanceYear == year,
            cancellationToken);
}
